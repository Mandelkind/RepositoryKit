//
//  RKSynchronizableRepository+CRUDNetworkingStorage.swift
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

// The repository is a *CRUD Networking Storage Repository* and the entity is a *Storage Entity*.
extension RKSynchronizableRepository where Self: RKCRUDNetworkingStorageRepository,
    Self.Entity: NSManagedObject, Self.Entity: RKNetworkingStorageEntity, Self.Entity: RKSynchronizable,
    Self.NetworkingRepository: RKCRUDNetworkingDictionaryRepository,
    Self.NetworkingRepository.Entity == RKDictionaryEntity,
    Self.StorageRepository: RKCRUDStorageRepository,
    Self.StorageRepository.Entity == Self.Entity {
    
    // MARK: - Synchronize methods
    /**
     Synchronizes the data of the `Storage Repository Store` with the data of the `Networking Repository Store`.
     
     1. Massive create/update of the unsynchronized objects on `Networking Repository Store` (those that the synchronizable attribute is false).
     2. Unsynchronize all the entities.
     3. Search all the `Networking Repository Store` entities (if it fails, set all the entities as synchronized).
     4. Synchronize the `Networking Repository Store` entities with the objects on the `Storage Repository Store`.
     5. Delete all the entities that are still unsynchronized (those that the synchronizable attribute is false).
     
     - Returns: A promise of `Void`.
     */
    public func synchronize() -> Promise<Void> {
        
        let predicate = NSPredicate(format: "\(synchronizableAttribute) == 'false'")
        
        return storage.search(predicate)
            .then(execute: massiveOperation)
            .then(execute: storage.search)
            .then { objects in
                self.setSynchronize(objects: objects, state: false)
            }
            .then(execute: networkingSearch)
            .then(execute: synchronize)
            .then { _ in
                self.delete(withPredicate: predicate)
            }
        
    }
    
    /**
     Synchronizes the specified data of the `Networking Repository Store` with the data of the `Storage Repository Store`.
     
     1. Update repeated objects.
     2. Create objects for keys not used.
     
     - Parameter entities: The networking entities fetched before.
     
     - Returns: A promise of `Void`.
     */
    public func synchronize(entities: [Self.NetworkingRepository.Entity]) -> Promise<Void> {
        
        var dictionary = Dictionary<String, Int>()
        for i in 0 ..< entities.count {
            guard let id = entities[i][networking.identificationKey] as? String else { continue }
            dictionary[id] = i
        }
        
        let ids = Array(dictionary.keys)
        let searchPredicate = NSPredicate(format: "id IN %@", ids)
        
        return storage.search(searchPredicate)
            .then { objects in
                self.update(dictionary: dictionary, objects: objects, entities: entities)
            }
            .then { newDictionary in
                self.create(dictionary: newDictionary, entities: entities)
            }
        
    }
    
    // MARK: - Utils
    /**
     Makes a POST to 'path'/collection with an array of the entities that needed to be updated
     or created on the `Networking Repository Store` (all encapsulated as 'data' key).
     In case of success, it will patch the entities if it is needed.
     In case of error, return it.
     */
    private func massiveOperation(_ objects: [Self.Entity]) -> Promise<Void> {
        
        return Promise { success, failure in
            
            guard objects.count > 0 else {
                success()
                return
            }
            
            var array = Array<Self.NetworkingRepository.Entity>()
            for object in objects {
                array.append(object.dictionary)
            }
            
            networking.store.request(method: .POST, path: "\(networking.path)/collection", parameters: ["data": array])
                .then { (entities: [Self.NetworkingRepository.Entity]) in
                    Promise { success, failure in
                        for index in 0 ..< entities.count {
                            objects[index].update(entities[index])
                        }
                        success()
                    }
                }
                .then(execute: success)
                .catch(execute: failure)
            
        }
        
    }
    
    /// Sets the synchronize attribute to the state specified by performing a selector.
    private func setSynchronize(objects: [Self.StorageRepository.Entity], state: Bool) -> Promise<[Self.StorageRepository.Entity]> {
        
        let synchronizeSelector = Selector(attribute: synchronizableAttribute)
        
        return Promise { success, failure in
            for object in objects {
                object.performSelector(onMainThread: synchronizeSelector, with: state, waitUntilDone: true)
            }
            success(objects)
            }
            .then(execute: storage.update)
        
    }
    
    /// Updates the storage entities with the networking ones.
    private func update(dictionary: Dictionary<String, Int>, objects: [Self.StorageRepository.Entity], entities: [Self.NetworkingRepository.Entity]) -> Promise<Dictionary<String, Int>> {
        
        var dictionary = dictionary
        
        for object in objects {
            if let key = object.id as? String, let index = dictionary[key] {
                object.update(entities[index])
                dictionary.removeValue(forKey: key)
            }
        }
        
        return storage.update(objects)
            .then { _ in dictionary }
        
    }
    
    /// Creates storage entities with the ones that are on the `Networking Repository Store` and not in the `Storage Repository Store`.
    private func create(dictionary: Dictionary<String, Int>, entities: [Self.NetworkingRepository.Entity]) -> Promise<Void> {
        
        var objects = Array<Self.NetworkingRepository.Entity>()
        for (_,v) in dictionary {
            objects.append(entities[v])
        }
        
        var promises = Array<Promise<Self.Entity>>()
        for object in objects {
            let promise = storage.create(object)
            promises.append(promise)
        }
        
        return when(resolved: promises)
            .then { _ in
                Promise { success, failure in
                    success()
                }
            }
        
    }
    
    /// Deletes with predicate.
    private func delete(withPredicate predicate: NSPredicate) -> Promise<Void> {
        
        return self.storage.search(predicate)
            .then(execute: storage.delete)
    
    }
    
    /// Searches all the entities on the networking. In case of failure, it will set all the entities synchronized again.
    private func networkingSearch(_ objects: [Self.StorageRepository.Entity]) -> Promise<[Self.NetworkingRepository.Entity]> {
        
        return Promise { success, failure in
            
            self.networking.search()
                .then(execute: success)
                .catch { error in
                    self.setSynchronize(objects: objects, state: true)
                        .then { _ in
                            failure(error)
                        }
                        .catch(execute: failure)
                }
            
        }
        
    }

}