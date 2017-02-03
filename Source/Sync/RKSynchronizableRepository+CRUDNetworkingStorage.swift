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

// MARK: - Main
extension RKSynchronizableRepository where Self: RKCRUDNetworkingStorageRepository, Entity: RKSynchronizable,
Self.StorageRepository.Entity == Entity, Self.NetworkingRepository.Entity == RKDictionaryEntity {
    
    /**
     Synchronizes both stores.
     
     1. Synchronize from the *Storage Repository Store* to the *Networking Repository Store*.
     2. Unsynchronize all the entities.
     3. Execute a search to the *Networking Repository Store*.
     4. Synchronize from the previous search to the *Storage Repository Store*.
     5. Delete all the entities that are still unsynchronized (those that the synchronizable attribute is false).
     
     - Returns: A promise of `Void`.
     */
    public func synchronize() -> Promise<Void> {
        
        return synchronize(search: networking.search)
        
    }
    
    /**
     Synchronizes both stores.
     
     1. Synchronize from the *Storage Repository Store* to the *Networking Repository Store*.
     2. Unsynchronize all the entities.
     3. Execute the networking search.
     4. Synchronize from the previous search to the *Storage Repository Store*.
     5. Delete all the entities that are still unsynchronized (those that the synchronizable attribute is false).
     
     - Parameter search: A closure that returns a promise of the networking entities that needs to be synchronized.
     
     - Returns: A promise of `Void`.
     */
    public func synchronize(search: @escaping (Void) -> Promise<[NetworkingRepository.Entity]>) -> Promise<Void> {
        
        let predicate = NSPredicate(format: "\(synchronizableAttribute) == 0")
        
        return synchronizeStorageToNetworking()
            .then(execute: storage.search)
            .then { objects in
                self.setSynchronize(objects: objects, state: false)
            }
            .then { objects in
                self.networkingSearch(search, objects: objects)
            }
            .then(execute: synchronizeNetworkingToStorage)
            .then { _ in
                self.delete(withPredicate: predicate)
        }
        
    }
    
    /**
     Synchronizes the data of the *Storage Repository Store* with the data of the *Networking Repository Store*.
     
     1. Search unsynchronized objects (those that the synchronizable attribute is false).
     2. Massive create/update on *Networking Repository Store*.
     
     - Returns: A promise of `Void`.
     */
    public func synchronizeStorageToNetworking() -> Promise<Void> {
        
        let predicate = NSPredicate(format: "\(synchronizableAttribute) == 0")
        
        return storage.search(predicate)
            .then(execute: massiveOperation)
        
    }
    
    /**
     Synchronizes the specified data of the *Networking Repository Store* with the data of the *Storage Repository Store*.
     
     1. Update repeated objects.
     2. Create objects for keys not used.
     
     - Parameter entities: The networking entities fetched before.
     
     - Returns: A promise of `Void`.
     */
    public func synchronizeNetworkingToStorage(entities: [NetworkingRepository.Entity]) -> Promise<Void> {
        
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
    
}

// MARK: - Util
extension RKSynchronizableRepository where Self: RKCRUDNetworkingStorageRepository, Entity: RKSynchronizable,
Self.StorageRepository.Entity == Entity, Self.NetworkingRepository.Entity == RKDictionaryEntity {
    
    /// Sets the synchronizable attribute to the state specified by performing a selector.
    fileprivate func setSynchronize(objects: [StorageRepository.Entity], state: Bool) -> Promise<[StorageRepository.Entity]> {
        
        guard StorageRepository.Entity.self is NSObject else {
            return Promise(error: RKError.badEntity)
        }
        
        let synchronizeSelector = Selector(attribute: synchronizableAttribute)
        
        for object in objects {
            (object as? NSObject)?.performSelector(onMainThread: synchronizeSelector, with: state, waitUntilDone: true)
        }
        
        return storage.update(objects)
        
    }
    
    /// Searches all the entities on the *Networking Repository Store*. In case of failure, it will set all the entities synchronized again.
    fileprivate func networkingSearch(_ search: (Void) -> Promise<[NetworkingRepository.Entity]>, objects: [StorageRepository.Entity]) -> Promise<[NetworkingRepository.Entity]> {
        
        return Promise { success, failure in
            
            search()
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
    
    /// Makes a POST to 'path'/collection with an array of the entities that needs to be updated/created (all encapsulated as 'data').
    fileprivate func massiveOperation(_ objects: [Entity]) -> Promise<Void> {
        
        guard objects.count > 0 else {
            return Promise(value: ())
        }
        
        var array = Array<NetworkingRepository.Entity>()
        for object in objects {
            array.append(object.dictionary)
        }
        
        return networking.store.request(method: .POST, path: "\(networking.path)/collection", parameters: ["data": array])
            .then { (entities: [NetworkingRepository.Entity]) -> Void in
                for index in 0 ..< entities.count {
                    objects[index].update(entities[index])
                }
        }
        
    }
    
    /// Updates the storage entities with the networking ones.
    fileprivate func update(dictionary: Dictionary<String, Int>, objects: [StorageRepository.Entity], entities: [NetworkingRepository.Entity]) -> Promise<Dictionary<String, Int>> {
        
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
    
    /// Creates storage entities with the ones that are on the *Networking Repository Store* and not in the *Storage Repository Store*.
    fileprivate func create(dictionary: Dictionary<String, Int>, entities: [NetworkingRepository.Entity]) -> Promise<Void> {
        
        var objects = Array<NetworkingRepository.Entity>()
        for (_,v) in dictionary {
            objects.append(entities[v])
        }
        
        var promises = Array<Promise<Entity>>()
        for object in objects {
            let promise = storage.create(object)
            promises.append(promise)
        }
        
        return when(resolved: promises)
            .then { _ -> Void in }
        
    }
    
    /// Deletes with predicate.
    fileprivate func delete(withPredicate predicate: NSPredicate) -> Promise<Void> {
        
        return storage.search(predicate)
            .then(execute: storage.delete)
        
    }
    
}
