//
//  RKCoreDataStack.swift
//
//  Copyright (c) 2016 Luciano Polit <lucianopolit@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import CoreData
import PromiseKit

// MARK: - Errors
/// Represents the possible errors that can be produced by the core data stack.
public enum RKCoreDataStackError: Error {
    
    /// Occurs when the model with the specified model name can not be found.
    case modelNotFound
    
    /// Occurs when the model can not be created.
    case modelNotCreated
    
    /// Occurs when the document folder can not be found.
    case documentFolderNotFound
    
}

// MARK: - Main
/// An object that manages the stack of core data with three contexts (persistence, main and background).
open class RKCoreDataStack: RKStorage {
    
    // MARK: - Constants
    private let kModelExtension: String = "momd"
    private let kDatabaseExtension: String = "sqlite"
    
    // MARK: - Properties
    /// The url that contains the database.
    open let databaseURL: URL
    /// The url that contains the model.
    open let modelURL: URL
    /// The name of the model.
    open let modelName: String
    /// The object of the model.
    open let model: NSManagedObjectModel
    /// The persistent coordinator of the model.
    open let coordinator: NSPersistentStoreCoordinator
    /// The context (in a private queue) that manages the persistence of the model.
    open let persistenceContext: NSManagedObjectContext
    /// The context (in a private queue) which purpose is to perform batches without blocking the application.
    open let backgroundContext: NSManagedObjectContext
    /// The context that manages all the information in the main queue.
    open let mainContext: NSManagedObjectContext
    
    // MARK: - Initialization
    /// Initializes and returns a newly allocated object with the specified model name and bundle.
    public init(modelName: String, bundle: Bundle = Bundle.main, addStore: Bool = true) throws {
        
        self.modelName = modelName
        
        guard let modelURL = bundle.url(forResource: modelName, withExtension: self.kModelExtension) else {
            throw RKCoreDataStackError.modelNotFound
        }
        self.modelURL = modelURL
        
        guard let model = NSManagedObjectModel(contentsOf: self.modelURL) else {
            throw RKCoreDataStackError.modelNotCreated
        }
        self.model = model
        
        self.coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        
        self.persistenceContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.persistenceContext.persistentStoreCoordinator = self.coordinator
        
        self.mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.mainContext.parent = self.persistenceContext
        
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.backgroundContext.parent = self.mainContext
        
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw RKCoreDataStackError.documentFolderNotFound
        }
        self.databaseURL = documentURL.appendingPathComponent("\(modelName).\(self.kDatabaseExtension)")
        
        guard addStore else { return }
        
        try self.coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.databaseURL, options: nil)
        
    }
    
}

// MARK: - Operations
extension RKCoreDataStack {
    
    /**
     Synchronously performs a given block on the main context.
     
     - Parameter block: The block that needs to be performed.
     
     - Returns: A promise with a generic type.
     */
    open func performOperation<T>(_ block: @escaping (NSManagedObjectContext) -> Promise<T>) -> Promise<T> {
        
        return mainContext.performAndWait {
            block(self.mainContext)
        }
        
    }
    
    /**
     Asynchronously performs a given block on the background context.
     
     - Parameter block: The block that needs to be performed.
     
     - Returns: A promise with a generic type.
     */
    open func performBackgroundOperation<T>(_ block: @escaping (NSManagedObjectContext) -> Promise<T>) -> Promise<T> {
        
        return backgroundContext.perform {
            block(self.backgroundContext)
                .then(execute: self.backgroundContext.save)
        }
        
    }
    
}

// MARK: - Save
extension RKCoreDataStack {
    
    /// Saves the main context and persists the data.
    open func save<T>(_ t: T) -> Promise<T> {
        
        return saveMainContext()
            .then(execute: savePersistentContext)
            .then { t }
        
    }
    
    private func saveMainContext() -> Promise<Void> {
        
        return Promise { success, failure in
            
            self.mainContext.performAndWait {
                
                if self.mainContext.hasChanges {
                    do {
                        try self.mainContext.save()
                        success()
                    }
                    catch {
                        failure(RKError.other(error))
                    }
                } else {
                    success()
                }
                
            }
            
        }
        
    }
    
    private func savePersistentContext() -> Promise<Void> {
        
        return Promise { success, failure in
            
            self.persistenceContext.perform {
                
                do {
                    try self.persistenceContext.save()
                    success()
                }
                catch {
                    failure(RKError.other(error))
                }
                
            }
            
        }
        
    }
    
}

// MARK: - Reset
extension RKCoreDataStack  {
    
    /// Empty the database.
    open func reset() throws {
        
        try coordinator.destroyPersistentStore(at: databaseURL, ofType: NSSQLiteStoreType , options: nil)
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseURL, options: nil)
        
    }
    
}
