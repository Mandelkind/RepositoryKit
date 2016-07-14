//
//  RKCRCUDNetworkingStorageRepository.swift
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
public protocol RKCRUDNetworkingStorageRepository: RKRepository, RKCRUDRepository {
    
    associatedtype NetworkingRepository: RKCRUDNetworkingRepository
    associatedtype StorageRepository: RKCRUDStorageRepository
    
    var networking: NetworkingRepository { get }
    var storage: StorageRepository { get }
    
}

// MARK: - Methods implementation
extension RKCRUDNetworkingStorageRepository
    where NetworkingRepository.Entity == Dictionary<String, AnyObject>,
    Entity == StorageRepository.Entity, Entity: NSManagedObject,
    Entity: DictionaryContextInitializable, Entity: Identifiable, Entity: DictionaryRepresentable, Entity: DictionaryUpdateable {
    
    // MARK: - Properties
    /// The model attribute that will be the reference if a managed object is up to date during the search method or not.
    public var updateableAttribute: String { return "update" }
    
    // MARK: - Create
    /**
     Creates an object on the `Storage` and the `Networking`.
     
     1. Create the managed object on the `Storage`.
     2. Make the request to the server to create it too.
     3. Update the managed object with the networking response.
     
     - Parameter entity: A `Dictionary` that is used to create the new `Entity`.
     
     - Returns: A promise of `Entity`.
     */
    public func create(entity: Dictionary<String, AnyObject>) -> Promise<Entity> {
        return storage.create(entity)
            .then { object in
                self.networking.create(object.dictionary)
                    .then(object.update)
                    .then{object}
            }.then(storage.update)
    }
    
    // MARK: - Read
    /**
     Searches all objects created on the server and creates it on the `Storage`.
     
     1. Make the request to find all the entities.
     2. Synchronize the data of the server with the data of the `Storage`.
     3. Make a storage search with all the managed objects updated.
     
     - Returns: A promise of an `Array` of `Entity`.
     */
    public func search() -> Promise<[Entity]> {
        return networking.search()
            .then(synchronize)
            .then(storage.search)
    }
    
    // MARK: - Update
    /**
     Updates an object on the server and the `Storage`.
     
     - Parameter entity: The entity that needs to be updated.
     
     - Returns: A promise of the `Entity` updated.
     */
    public func update(entity: Entity) -> Promise<Entity> {
        return storage.update(entity)
            .then { object in
                self.networking.update(object.dictionary)
                    .then(object.update)
                    .then{object}
            }.then(storage.update)
    }
    
    // MARK: - Delete
    /**
     Deletes an object on the server and the `Storage`.
     
     - Parameter entity: The entity that needs to be deleted.
     
     - Returns: A promise of the `Entity` deleted.
     */
    public func delete(entity: Entity) -> Promise<Void> {
        return networking.delete(entity.dictionary)
            .then { self.storage.delete(entity) }
    }
    
    // MARK: - Utils
    /**
     Synchronize the data of the server with the data of the `Storage`.
     
     1. Batch update (set updateable attribute to false).
     2. Update repeated objects.
     3. Create objects for keys not used.
     4. Batch delete for objects which updateable attribute is still in false.
     
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
        let predicate = NSPredicate(format: "id IN %@", ids)
        
        return storage.batchUpdate([updateableAttribute: false])
            .then { self.storage.search(predicate) }
            .then { objects in
                self.updateRepeatedObjects(&dictionary, objects: objects, entities: entities)
            }.then { _ in
                self.createNewObjects(dictionary, entities: entities)
            }.then { _ in
                self.storage.batchDelete(NSPredicate(format: "\(self.updateableAttribute) == false"))
            }
        
    }
    
    private func updateRepeatedObjects(inout dictionary: Dictionary<String, Int>, objects: [StorageRepository.Entity], entities: [NetworkingRepository.Entity]) -> Promise<[StorageRepository.Entity]> {
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
    
    private func createNewObjects(dictionary: Dictionary<String, Int>, entities: [NetworkingRepository.Entity]) -> Promise<Void> {
        var other = Array<NetworkingRepository.Entity>()
        for (_,v) in dictionary {
            other.append(entities[v])
        }
        return storage.create(other)
    }
    
}