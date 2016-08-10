//
//  RKCRUDStorageRepository.swift
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

// MARK: - Main
public protocol RKCRUDStorageRepository: RKStorageRepository, RKCRUDRepository { }

// MARK: - Create
extension RKCRUDStorageRepository where Entity: DictionaryContextInitializable {
    
    /**
     Creates a managed object on the main context with the specified `Dictionary`.
     
     - Parameter entity: A `Dictionary` that initialize the object.
     
     - Returns: A promise of `Entity`.
     */
    public func create(entity: Dictionary<String, AnyObject>) -> Promise<Entity> {
        
        return storage.performOperation { context in
            Promise { success, failure in
                guard let object = Entity(dictionary: entity, context: context) else {
                    failure(RKError.initialization)
                    return
                }
                success(object)
            }
        }.then(storage.save)
        
    }
    
    /**
     Creates *n* managed objects on a background context with the specified `Array` of `Dictionary`.
     
     - Parameter entity: An `Array` of `Dictionary` that initialize the objects.
     
     - Returns: A promise of `Void`.
     */
    public func create(entities: Array<Dictionary<String, AnyObject>>) -> Promise<Void> {
        
        return storage.performBackgroundOperation { context in
            Promise { success, failure in
                var objects = [Entity]()
                var i = 0
                for entity in entities {
                    if let ent = Entity(dictionary: entity, context: context) {
                        objects.append(ent)
                    }
                    
                    i += 1
                    if i % 100 == 0 {
                        context.save(Void)
                    }
                }
                success()
            }
        }.then(storage.save)
        
    }
    
}

// MARK: - Read
extension RKCRUDStorageRepository where Entity: NSManagedObject {
    
    /**
     Searches all managed objects on the main context.
     
     - Returns: A promise of an `Array` of `Entity`.
     */
    public func search() -> Promise<[Entity]> {
        
        return search(nil)
        
    }
    
    /**
     Searches with a predicate for managed objects on the main context.
     
     - Parameter predicate: A `NSPredicate` that is used to make the fetch request.
     
     - Returns: A promise of an `Array` of `Entity`.
     */
    public func search(predicate: NSPredicate?) -> Promise<[Entity]> {
        
        return storage.performOperation { context in
            Promise { success, failure in
                
                let request = NSFetchRequest(entityName: self.name)
                request.predicate = predicate
                
                do {
                    guard let results = try context.executeFetchRequest(request) as? [Entity] else {
                        failure(RKError.notFound)
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
extension RKCRUDStorageRepository where Entity: NSManagedObject {
    
    /**
     Updates all uncommited changes for the specified entity on the main context.
     
     - Parameter entity: The entity that needs to be updated.
     
     - Returns: A promise of the `Entity` updated.
     */
    public func update(entity: Entity) -> Promise<Entity> {
        return storage.save()
            .then{entity}
    }
    
    /**
     Updates all uncommited changes for the specified entities on the main context.
     
     - Parameter entities: The `Array` of `Entity` that needs to be updated.
     
     - Returns: A promise of the `Array` of `Entity` updated.
     */
    public func update(entities: [Entity]) -> Promise<[Entity]> {
        return storage.save()
            .then{entities}
    }
    
    /**
     Updates all managed objects fetched with the specified predicate and properties on the main context.
     
     - Parameter properties: The properties that needs to be updated.
     - Parameter predicate: A `NSPredicate` that is used to make the fetch request.
     
     - Returns: A promise of `Void`.
     */
    public func batchUpdate(properties: Dictionary<String, AnyObject>, predicate: NSPredicate? = nil) -> Promise<Void> {
        
        return storage.performOperation { context in
            Promise { success, failure in
                
                guard let entityDescription = NSEntityDescription.entityForName(self.name, inManagedObjectContext: context) else {
                    failure(RKError.notFound)
                    return
                }
                
                let batchUpdateRequest = NSBatchUpdateRequest(entity: entityDescription)
                batchUpdateRequest.propertiesToUpdate = properties
                batchUpdateRequest.resultType = .StatusOnlyResultType
                
                do {
                    try context.executeRequest(batchUpdateRequest) as? NSBatchUpdateResult
                    success()
                }
                catch {
                    failure(RKError.other(error))
                }
                
            }
        }.then(storage.save)
        
    }
    
}

// MARK: - Delete
extension RKCRUDStorageRepository where Entity: NSManagedObject {
    
    /**
     Deletes the specified entity on the main context.
     
     - Parameter entity: The managed object that needs to be deleted.
     
     - Returns: A promise of `Void`.
     */
    public func delete(entity: Entity) -> Promise<Void> {
        
        return storage.performOperation { context in
            Promise { success, failure in
                context.deleteObject(entity)
                success()
            }
        }.then(storage.save)
        
    }
    
    /**
     Deletes the specified entities on the main context.
     
     - Parameter entities: The `Array` of managed objects that needs to be deleted.
     
     - Returns: A promise of `Void`.
     */
    public func delete(entities: [Entity]) -> Promise<Void> {
        
        return storage.performOperation { context in
            Promise { success, failure in
                var i = 0
                for entity in entities {
                    context.deleteObject(entity)
                    
                    i += 1
                    if i % 100 == 0 {
                        context.save(Void)
                    }
                }
                success()
            }
        }.then(storage.save)
        
    }
    
    /**
     Deletes all managed objects fetched with the specified predicate on the main context.
     
     - Parameter predicate: A `NSPredicate` that is used to make the fetch request.
     
     - Returns: A promise of `Void`.
     */
    public func batchDelete(predicate: NSPredicate? = nil) -> Promise<Void> {
        
        return storage.performOperation { context in
            Promise { success, failure in
                
                let fetchRequest = NSFetchRequest(entityName: self.name)
                fetchRequest.predicate = predicate
                
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                batchDeleteRequest.resultType = .ResultTypeStatusOnly
                
                do {
                    try context.executeRequest(batchDeleteRequest)
                    success()
                }
                catch {
                    failure(RKError.other(error))
                }
                
            }
        }.then(storage.save)
        
    }
    
}