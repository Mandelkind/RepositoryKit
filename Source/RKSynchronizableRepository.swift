//
//  RKSynchronizableRepository.swift
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

/// Enables to synchronize multiple repositories.
public protocol RKSynchronizableRepository {
    
    /// The property name that will be the reference if a object is up to date or not.
    var synchronizableAttribute: String { get }
    
    /// Synchronizes the data of the different repositories.
    func synchronize() -> Promise<Void>
    
}

// The repository is a *CRUD Networking Storage Repository* and the entity is a *Storage Entity*.
extension RKSynchronizableRepository where Self: RKCRUDNetworkingStorageRepository,
    Self.Entity: NSManagedObject, Self.Entity: RKNetworkingStorageEntity, Self.Entity: RKSynchronizable,
    Self.NetworkingRepository: RKCRUDNetworkingDictionaryRepository,
    Self.NetworkingRepository.Entity == RKDictionaryEntity,
    Self.StorageRepository: RKCRUDStorageRepository,
    Self.StorageRepository.Entity == Self.Entity {
    
    // MARK: - Synchronize methods
    /**
     Synchronizes the data of the `Storage store` with the data of the `Networking store`.
     
     1. Massive create/update of the unsynchronized objects on `Networking store` (those that the synchronizable attribute is false).
     2. Unsynchronize all the entities.
     3. Search all the `Networking store` entities (if it fails, set all the entities as synchronized).
     4. Synchronize the `Networking store` entities with the objects on the `Storage store`.
     5. Delete all the entities that are still unsynchronized (those that the synchronizable attribute is false).
     
     - Returns: A promise of `Void`.
     */
    public func synchronize() -> Promise<Void> {
        
        let predicate = NSPredicate(format: "\(synchronizableAttribute) == 'false'")
        
        return storage.search(predicate)
            .then(massiveOperation)
            .then(storage.search)
            .then { objects in
                self.setSynchronize(objects, state: false)
            }
            .then(networkingSearch)
            .then(synchronize)
            .then { _ in
                self.delete(withPredicate: predicate)
            }
        
    }
    
    /**
     Synchronizes the specified data of the `Networking store` with the data of the `Storage store`.
     
     1. Update repeated objects.
     2. Create objects for keys not used.
     
     - Parameter entities: The networking entities fetched before.
     
     - Returns: A promise of `Void`.
     */
    public func synchronize(entities: [NetworkingRepository.Entity]) -> Promise<Void> {
        
        var dictionary = Dictionary<String, Int>()
        for i in 0 ..< entities.count {
            guard let id = entities[i][networking.identificationKey] as? String else { continue }
            dictionary[id] = i
        }
        
        let ids = Array(dictionary.keys)
        let searchPredicate = NSPredicate(format: "id IN %@", ids)
        
        return storage.search(searchPredicate)
            .then { objects in
                self.update(&dictionary, objects: objects, entities: entities)
            }.then { _ in
                self.create(dictionary, entities: entities)
            }
        
    }
    
    // MARK: - Utils
    /**
     Makes a POST to 'path'/collection with an array of the entities that needed to be updated
     or created on the `Networking store` (all encapsulated as 'data' key).
     In case of success, it will patch the entities if it is needed.
     In case of error, return it.
     */
    private func massiveOperation(objects: [Entity]) -> Promise<Void> {
        
        return Promise { success, failure in
            
            guard objects.count > 0 else {
                success()
                return
            }
            
            var array = Array<Dictionary<String, AnyObject>>()
            for object in objects {
                array.append(object.dictionary)
            }
            
            networking.store.request(.POST, path: "\(networking.path)/collection", parameters: ["data": array])
                .then { (entities: [NetworkingRepository.Entity]) in
                    Promise { success, failure in
                        for index in 0 ..< entities.count {
                            objects[index].update(entities[index])
                        }
                        success()
                    }
                }.then(success)
                .error(failure)
            
        }
        
    }
    
    /// Sets the synchronize attribute to the state specified by performing a selector.
    private func setSynchronize(objects: [StorageRepository.Entity], state: Bool) -> Promise<[StorageRepository.Entity]> {
        
        let synchronizeSelector = Selector(attribute: synchronizableAttribute)
        
        return Promise { success, failure in
            for object in objects {
                object.performSelector(synchronizeSelector, withObject: state)
            }
            success(objects)
            }.then(storage.update)
        
    }
    
    /// Updates the storage entities with the networking ones.
    private func update(inout dictionary: Dictionary<String, Int>, objects: [StorageRepository.Entity], entities: [NetworkingRepository.Entity]) -> Promise<[StorageRepository.Entity]> {
        
        return Promise { success, failure in
            for object in objects {
                if let key = object.id as? String, let index = dictionary[key] {
                    object.update(entities[index])
                    dictionary.removeValueForKey(key)
                }
            }
            success(objects)
            }.then(storage.update)
        
    }
    
    /// Creates storage entities with the ones that are on the `Networking store` and not in the `Storage store`.
    private func create(dictionary: Dictionary<String, Int>, entities: [NetworkingRepository.Entity]) -> Promise<Void> {
        
        var objects = Array<NetworkingRepository.Entity>()
        for (_,v) in dictionary {
            objects.append(entities[v])
        }
        
        var promises = Array<Promise<Entity>>()
        for object in objects {
            let promise = storage.create(object)
            promises.append(promise)
        }
        
        return when(promises)
            .then{ _ in
                Promise { success, failure in
                    success()
                }
            }
        
    }
    
    /// Deletes with predicate.
    private func delete(withPredicate predicate: NSPredicate) -> Promise<Void> {
        
        return self.storage.search(predicate)
            .then(storage.delete)
    
    }
    
    /// Searches all the entities on the networking. In case of failure, it will set all the entities synchronized again.
    private func networkingSearch(objects: [StorageRepository.Entity]) -> Promise<[NetworkingRepository.Entity]> {
        
        return Promise { success, failure in
            
            self.networking.search()
                .then(success)
                .error { error in
                    self.setSynchronize(objects, state: true)
                    failure(error)
                }
            
        }
        
    }

}