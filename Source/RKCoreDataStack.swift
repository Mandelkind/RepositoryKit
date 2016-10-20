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
private enum RKCoreDataStackError: String {
    case ModelNotFound = "Unable to find %@ in the %@ bundle"
    case ModelNotCreated = "Unable to create a model from %@"
    case DocumentFolderNotFound = "Unable to find the document folder"
    case StoreNotAdded = "Unable to add store at %@"
}

// MARK: - Main
/// An object that manages the stack of core data with three contexts (persistence, main and background).
public class RKCoreDataStack: RKStorage {
    
    // MARK: - Constants
    private let kModelExtension: String = "momd"
    private let kDatabaseExtension: String = "sqlite"
    
    // MARK: - Properties
    /// The url that contains the database.
    public let databaseURL: NSURL
    /// The url that contains the model.
    public let modelURL: NSURL
    /// The name of the model.
    public let modelName: String
    /// The object of the model.
    public let model: NSManagedObjectModel
    /// The persistent coordinator of the model.
    public let coordinator: NSPersistentStoreCoordinator
    /// The context (in a private queue) that manages the persistence of the model.
    public let persistenceContext: NSManagedObjectContext
    /// The context (in a private queue) which purpose is to perform batches without blocking the application.
    public let backgroundContext: NSManagedObjectContext
    /// The context that manages all the information in the main queue.
    public let mainContext: NSManagedObjectContext
    
    // MARK: - Initialization
    /// Initializes and returns a newly allocated object with the specified model name.
    public convenience init?(modelName: String) {
        self.init(modelName: modelName, bundle: NSBundle.mainBundle())
    }
    
    /// Initializes and returns a newly allocated object with the specified model name and bundle.
    public init?(modelName: String, bundle: NSBundle) {
        
        self.modelName = modelName
        
        guard let modelURL = bundle.URLForResource(modelName, withExtension: self.kModelExtension) else {
            NSLog(RKCoreDataStackError.ModelNotFound.rawValue, modelName, bundle.infoDictionary!["CFBundleName"] as! String)
            return nil
        }
        self.modelURL = modelURL
        
        guard let model = NSManagedObjectModel(contentsOfURL: self.modelURL) else {
            NSLog(RKCoreDataStackError.ModelNotCreated.rawValue, self.modelURL)
            return nil
        }
        self.model = model
        
        self.coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        
        self.persistenceContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        self.persistenceContext.persistentStoreCoordinator = self.coordinator
        
        self.mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.mainContext.parentContext = self.persistenceContext
        
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        self.backgroundContext.parentContext = self.mainContext
        
        guard let documentUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
            NSLog(RKCoreDataStackError.DocumentFolderNotFound.rawValue)
            return nil
        }
        self.databaseURL = documentUrl.URLByAppendingPathComponent("\(modelName).\(self.kDatabaseExtension)")
        
        do {
            try self.coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.databaseURL, options: nil)
        }
        catch {
            NSLog(RKCoreDataStackError.StoreNotAdded.rawValue, self.databaseURL)
        }
        
    }
    
}

// MARK: - Operations
public extension RKCoreDataStack {
    
    /**
     Synchronously performs a given block on the main context.
     
     - Parameter block: The block that needs to be performed.
     
     - Returns: A promise with a generic type.
    */
    public func performOperation<T>(block: NSManagedObjectContext -> Promise<T>) -> Promise<T> {
        
        return self.mainContext.performBlockAndWait {
            block(self.mainContext)
        }
        
    }
    
    /**
     Asynchronously performs a given block on the background context.
     
     - Parameter block: The block that needs to be performed.
     
     - Returns: A promise with a generic type.
    */
    public func performBackgroundOperation<T>(block: NSManagedObjectContext -> Promise<T>) -> Promise<T> {
        
        return self.backgroundContext.performBlock {
            block(self.backgroundContext)
            .then(self.backgroundContext.save)
        }
        
    }
    
}

// MARK: - Reset
public extension RKCoreDataStack  {
    
    /// Empty the database.
    public func reset() throws {
        
        try coordinator.destroyPersistentStoreAtURL(self.databaseURL, withType:NSSQLiteStoreType , options: nil)
        try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.databaseURL, options: nil)
        
    }
    
}

// MARK: - Save
public extension RKCoreDataStack {
    
    /// Save the main context and persist the data.
    public func save<T>(t: T) -> Promise<T> {
        
        return saveMainContext()
            .then(savePersistentContext)
            .then{t}
        
    }
    
    private func saveMainContext() -> Promise<Void> {
        
        return Promise { success, failure in
            
            self.mainContext.performBlockAndWait() {
                
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
            
            self.persistenceContext.performBlock() {
                
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