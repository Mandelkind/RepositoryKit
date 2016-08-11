//
//  RKSynchronizer.swift
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

public protocol RKSynchronizer {
    
    /// The property name that will be the reference if a object is up to date or not.
    var synchronizableAttribute: String { get }
    
    /// Synchronizes the data of the different repositories.
    func synchronize() -> Promise<Void>
    
}

extension RKSynchronizer where Self: RKCRUDNetworkingStorageRepository,
    Self.StorageRepository.Entity == Self.Entity,
    Self.NetworkingRepository.Entity == Dictionary<String, AnyObject>,
    Self.NetworkingRepository: RKDictionaryIdentifier,
    Self.Entity: NSManagedObject,
    Self.Entity: DictionaryRepresentable,
    Self.Entity: DictionaryContextInitializable,
    Self.Entity: DictionaryUpdateable,
    Self.Entity: Identifiable,
    Self.Entity: Synchronizable {
    
    // MARK: - Synchronize methods
    /**
     Synchronizes the data of the `Networking` with the data of the `Storage`.
     
     1. Create the unsynchronized objects on `Networking` (those that the synchronizable attribute is false).
     2. Search all the entities of `Networking`.
     3. Synchronize this entities with the objects on the `Storage`.
     
     - Returns: A promise of `Void`.
    */
    public func synchronize() -> Promise<Void> {
        
        let predicate = NSPredicate(format: "\(synchronizableAttribute) == 'false'")
        
        return storage.search(predicate)
            .then(create)
            .then(networking.search)
            .then(synchronize)
        
    }
    
    /**
     Synchronizes the specified data of the `Networking` with the data of the `Storage`.
     
     1. Unsynchronize all (set synchronized attribute to false).
     2. Update repeated objects.
     3. Create objects for keys not used.
     4. Batch delete for objects which synchronizable attribute is still in false.
     
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
        let deletePredicate = NSPredicate(format: "\(synchronizableAttribute) == 'false'")
        
        return storage.search()
            .then(unsynchronize)
            .then { objects in
                self.update(&dictionary, objects: objects, entities: entities)
            }.then { _ in
                self.create(dictionary, entities: entities)
            }.then { _ in
                self.storage.search(deletePredicate)
            }.then(storage.delete)
        
    }
    
    // MARK: - Utils
    private func unsynchronize(objects: [StorageRepository.Entity]) -> Promise<[StorageRepository.Entity]> {
        
        let synchronizeSelector = Selector(attribute: synchronizableAttribute)
        
        return Promise { success, failure in
            for object in objects {
                object.performSelector(synchronizeSelector, withObject: false)
            }
            success(objects)
        }.then(storage.update)
        
    }
    
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
    
    private func create(dictionary: Dictionary<String, Int>, entities: [NetworkingRepository.Entity]) -> Promise<Void> {
        
        var other = Array<NetworkingRepository.Entity>()
        for (_,v) in dictionary {
            other.append(entities[v])
        }
        
        return storage.create(other)
        
    }
    
    private func create(objects: [Entity]) -> Promise<Void> {
        
        return Promise { success, failure in
            var promises = Array<Promise<Void>>()
            for object in objects {
                var promise = self.networking.create(object.dictionary)
                    .then(object.update)
                promises.append(promise)
            }
            
            when(promises)
                .then(success)
                .error(failure)
        }
        
    }
    
}