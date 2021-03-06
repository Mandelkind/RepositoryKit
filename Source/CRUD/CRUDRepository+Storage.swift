//
//  CRUDRepository+Storage.swift
//
//  Copyright (c) 2016-2017 Luciano Polit <lucianopolit@gmail.com>
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

// MARK: - Main
/// Represents a *CRUD Storage Repository* and its entity is a *Storage Entity*.
public protocol CRUDStorageRepository: CRUDRepository, StorageRepository {
    
    /// The associated entity type.
    associatedtype Entity: StorageEntity
    
}

// MARK: - Create
extension CRUDStorageRepository {
    
    /**
     Creates a managed object on the main context with the specified `Dictionary`.
     
     - Parameter entity: A `Dictionary` that initialize the object.
     
     - Returns: A promise of `Entity`.
     */
    public func create(_ entity: Dictionary<String, Any>) -> Promise<Entity> {
        
        return store.performOperation { context in
            Promise { success, failure in
                guard let object = Entity(dictionary: entity, context: context) else {
                    failure(RKError.parsing)
                    return
                }
                success(object)
            }
            }.then(execute: store.save)
        
    }
    
    /**
     Creates *n* managed objects on a background context with the specified `Array` of `Dictionary`.
     
     - Parameter entity: An `Array` of `Dictionary` that initialize the objects.
     
     - Returns: A promise of `Void`.
     */
    public func create(_ entities: [Dictionary<String, Any>]) -> Promise<Void> {
        
        return store.performBackgroundOperation { context in
            var objects = Array<Entity>()
            var i = 0
            for entity in entities {
                if let ent = Entity(dictionary: entity, context: context) {
                    objects.append(ent)
                }
                
                i += 1
                if i % 100 == 0 {
                    try? context.save()
                }
            }
            return Promise(value: ())
            }.then(execute: store.save)
        
    }
    
}

// MARK: - Read
extension CRUDStorageRepository {
    
    /**
     Searches all managed objects on the main context.
     
     - Returns: A promise of an `Array` of `Entity`.
     */
    public func search() -> Promise<[Entity]> {
        
        return search(nil)
        
    }
    
    /**
     Searches with a predicate for managed objects on the main context.
     
     - Parameter predicate: A `Predicate` that is used to make the `FetchRequest`.
     
     - Returns: A promise of an `Array` of `Entity`.
     */
    public func search(_ predicate: NSPredicate?) -> Promise<[Entity]> {
        
        return store.performOperation { context in
            Promise { success, failure in
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.name)
                request.predicate = predicate
                
                do {
                    guard let results = try context.fetch(request) as? [Entity] else {
                        failure(RKError.casting)
                        return
                    }
                    success(results)
                }
                catch {
                    failure(RKError.other(error))
                }
                
            }
        }
        
    }
    
}

// MARK: - Update
extension CRUDStorageRepository {
    
    /**
     Updates all uncommited changes for the specified entity on the main context.
     
     - Parameter entity: The entity that needs to be updated.
     
     - Returns: A promise of `Entity`.
     */
    public func update(_ entity: Entity) -> Promise<Entity> {
        return store.save()
            .then { entity }
    }
    
    /**
     Updates all uncommited changes for the specified entities on the main context.
     
     - Parameter entities: The `Array` of `Entity` that needs to be updated.
     
     - Returns: A promise of an `Array` of `Entity`.
     */
    public func update(_ entities: [Entity]) -> Promise<[Entity]> {
        return store.save()
            .then { entities }
    }
    
}

// MARK: - Delete
extension CRUDStorageRepository {
    
    /**
     Deletes the specified entity on the main context.
     
     - Parameter entity: The managed object that needs to be deleted.
     
     - Returns: A promise of `Void`.
     */
    public func delete(_ entity: Entity) -> Promise<Void> {
        
        return store.performOperation { context in
            Promise(value: entity)
                .then(execute: context.delete)
            }.then(execute: store.save)
        
    }
    
    /**
     Deletes the specified entities on the main context.
     
     - Parameter entities: The `Array` of managed objects that needs to be deleted.
     
     - Returns: A promise of `Void`.
     */
    public func delete(_ entities: [Entity]) -> Promise<Void> {
        
        return store.performOperation { context in
            var i = 0
            for entity in entities {
                try? context.delete(entity)
                
                i += 1
                if i % 100 == 0 {
                    try? context.save()
                }
            }
            return Promise(value: ())
            }.then(execute: store.save)
        
    }
    
}
