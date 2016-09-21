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

/// Represents a *CRUD Networking Storage Repository*.
public typealias RKCRUDNetworkingStorageRepository = protocol<RKCRUDRepository, RKNetworkingStorageRepository>

extension RKCRUDRepository where Self: RKNetworkingStorageRepository,
    Self.NetworkingRepository: RKCRUDNetworkingRepository,
    Self.NetworkingRepository: RKDictionaryIdentifier,
    Self.NetworkingRepository.Entity == Dictionary<String, AnyObject>,
    Self.StorageRepository: RKCRUDStorageRepository,
    Self.StorageRepository.Entity == Self.Entity,
    Self.Entity: NSManagedObject,
    Self.Entity: RKNetworkingStorageEntity {
    
    // MARK: - Create
    /**
     Creates an object on the `Storage` and the `Networking`.
     
     1. Create the managed object on the `Storage`.
     2. Make the request to the `Networking` to create it too.
     3. Update the managed object with the networking response.
     
     - Parameter entity: A `Dictionary` that is used to create the new `Entity`.
     
     - Returns: A promise of `Entity`.
     */
    public func create(entity: Dictionary<String, AnyObject>) -> Promise<Entity> {
        return storage.create(entity)
            .then { object in
                self.networking.create(object.dictionary)
                    .then { dictionary in
                        Promise { success, failure in
                            object.update(dictionary)
                            success(object)
                        }
                }
            }.then(storage.update)
    }
    
    // MARK: - Read
    /**
     Searches all objects created on the `Networking` and creates it on the `Storage`.
     
     1. Make the request to find all the entities.
     2. Synchronize the data of the `Networking` with the data of the `Storage`.
     3. Make a storage search with all the managed objects updated.
     
     - Returns: A promise of an `Array` of `Entity`.
     */
    public func search() -> Promise<[Entity]> {
        return storage.search()
    }
    
    // MARK: - Update
    /**
     Updates an object on the `Networking` and the `Storage`.
     
     - Parameter entity: The entity that needs to be updated.
     
     - Returns: A promise of the `Entity` updated.
     */
    public func update(entity: Entity) -> Promise<Entity> {
        return storage.update(entity)
            .then { object in
                self.networking.update(object.dictionary)
                    .then { dictionary in
                        Promise { success, failure in
                            object.update(dictionary)
                            success(object)
                        }
                }
            }.then(storage.update)
    }
    
    // MARK: - Delete
    /**
     Deletes an object on the `Networking` and the `Storage`.
     
     - Parameter entity: The entity that needs to be deleted.
     
     - Returns: A promise of the `Entity` deleted.
     */
    public func delete(entity: Entity) -> Promise<Void> {
        return networking.delete(entity.dictionary)
            .then { self.storage.delete(entity) }
    }
    
}