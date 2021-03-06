//
//  CRUDRepository+NetworkingStorage.swift
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
/// Represents a *CRUD Networking Storage Repository* and its entity is a *Networking Storage Entity*.
public protocol CRUDNetworkingStorageRepository: CRUDRepository, NetworkingStorageRepository {
    
    /// The associated entity type.
    associatedtype Entity: NetworkingStorageEntity
    /// The associated networking repository type.
    associatedtype NetworkingRepository: CRUDNetworkingDictionaryRepository
    /// The associated storage repository type.
    associatedtype StorageRepository: CRUDStorageRepository
    
}

// MARK: - Create
extension CRUDNetworkingStorageRepository where StorageRepository.Entity == Entity, NetworkingRepository.Entity == DictionaryEntity {
    
    /**
     Creates an object on the *Storage Repository Store* and the *Networking Repository Store*.
     
     1. Create the managed object on the *Storage Repository Store*.
     2. Make the request to the *Networking Repository Store* to create it too.
     3. Update the managed object with the networking response.
     
     - Parameter entity: A `Dictionary` that is used to create the new `Entity`.
     
     - Returns: A promise of `Entity`.
     */
    public func create(_ entity: Dictionary<String, Any>) -> Promise<Entity> {
        return storage.create(entity)
            .then { object in
                self.networking.create(object.dictionary)
                    .then(execute: object.update)
                    .then { object }
            }
            .then(execute: storage.update)
    }
    
}

// MARK: - Read
extension CRUDNetworkingStorageRepository where StorageRepository.Entity == Entity, NetworkingRepository.Entity == DictionaryEntity {
    
    /**
     Searches all objects created on the *Networking Repository Store* and creates it on the *Storage Repository Store*.
     
     1. Make the request to find all the entities.
     2. Synchronize the data of the *Networking Repository Store* with the data of the *Storage Repository Store*.
     3. Make a storage search with all the managed objects updated.
     
     - Returns: A promise of an `Array` of `Entity`.
     */
    public func search() -> Promise<[Entity]> {
        return storage.search()
    }
    
}

// MARK: - Update
extension CRUDNetworkingStorageRepository where StorageRepository.Entity == Entity, NetworkingRepository.Entity == DictionaryEntity {
    
    /**
     Updates an object on the *Networking Repository Store* and the *Storage Repository Store*.
     
     - Parameter entity: The entity that needs to be updated.
     
     - Returns: A promise of `Entity`.
     */
    public func update(_ entity: Entity) -> Promise<Entity> {
        return storage.update(entity)
            .then { object in
                self.networking.update(object.dictionary)
                    .then(execute: object.update)
                    .then { object }
            }
            .then(execute: storage.update)
    }
    
}

// MARK: - Delete
extension CRUDNetworkingStorageRepository where StorageRepository.Entity == Entity, NetworkingRepository.Entity == DictionaryEntity {
    
    /**
     Deletes an object on the *Networking Repository Store* and the *Storage Repository Store*.
     
     - Parameter entity: The entity that needs to be deleted.
     
     - Returns: A promise of `Void`.
     */
    public func delete(_ entity: Entity) -> Promise<Void> {
        return networking.delete(entity.dictionary)
            .then { self.storage.delete(entity) }
    }
    
}
