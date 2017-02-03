//
//  RKCRUDNetworkingDictionaryRepository.swift
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

import PromiseKit

// MARK: - Main
/// Represents a *CRUD Networking Dictionary Repository*.
public typealias RKCRUDNetworkingDictionaryRepository = RKCRUDNetworkingRepository & RKDictionaryIdentifier

// MARK: - Create
extension RKCRUDNetworkingRepository where Self: RKCRUDNetworkingDictionaryRepository, Entity == RKDictionaryEntity {
    
    /**
     Makes a request to the *Store* with the purpose of creating a new entity.
     
     - Parameter entity: A `Dictionary` that is used to create the new entity on the *Store*.
     
     - Returns: A promise of `Entity`.
     */
    public func create(_ entity: Dictionary<String, Any>) -> Promise<Entity> {
        
        return store.request(method: .POST, path: "\(path)", parameters: entity)
            .then { dictionary in
                RKDictionaryTransformer.merge(old: entity, new: dictionary)
        }
        
    }
    
}

// MARK: - Read
extension RKCRUDNetworkingRepository where Self: RKCRUDNetworkingDictionaryRepository, Entity == RKDictionaryEntity {
    
    /**
     Makes a request to the *Store* with the purpose of finding an entity with a specified unique identifier.
     
     - Parameter identifier: A `CustomStringConvertible` that is used to identify the entity.
     
     - Returns: A promise of `Entity`.
     */
    public func search(_ identifier: CustomStringConvertible) -> Promise<Entity> {
        
        return store.request(method: .GET, path: "\(path)/\(identifier)")
        
    }
    
    /**
     Makes a request to the *Store* with the purpose of finding all the entities.
     
     - Returns: A promise of an `Array` of `Entity`.
     */
    public func search() -> Promise<[Entity]> {
        
        return store.request(method: .GET, path: "\(path)")
        
    }
    
}

// MARK: - Update
extension RKCRUDNetworkingRepository where Self: RKCRUDNetworkingDictionaryRepository, Entity == RKDictionaryEntity {
    
    /**
     Makes a request to the *Store* with the purpose of updating an entity with a specific unique identifier.
     
     - Parameter entity: The entity that needs to be updated.
     
     - Returns: A promise of `Entity`.
     */
    public func update(_ entity: Entity) -> Promise<Entity> {
        
        return Promise(value: entity)
            .then(execute: entityIdentifiable)
            .then { identifier in
                self.store.request(method: .PUT, path: "\(self.path)/\(identifier)", parameters: entity)
            }
            .then { dictionary in
                RKDictionaryTransformer.merge(old: entity, new: dictionary)
        }
        
    }
    
}

// MARK: - Delete
extension RKCRUDNetworkingRepository where Self: RKCRUDNetworkingDictionaryRepository, Entity == RKDictionaryEntity {
    
    /**
     Makes a request to the *Store* with the purpose of deleting an entity with a specific unique identifier.
     
     - Parameter entity: The entity that needs to be deleted.
     
     - Returns: A promise of `Void`.
     */
    public func delete(_ entity: Entity) -> Promise<Void> {
        
        return Promise(value: entity)
            .then(execute: entityIdentifiable)
            .then { identifier in
                self.store.request(method: .DELETE, path: "\(self.path)/\(identifier)")
        }
        
    }
    
}

// MARK: - Util
extension RKCRUDNetworkingRepository where Self: RKCRUDNetworkingDictionaryRepository, Entity == RKDictionaryEntity {
    
    /// Attempts to recognize the entity by the identification key.
    fileprivate func entityIdentifiable(_ entity: Entity) throws -> CustomStringConvertible {
        
        guard let identifier = entity[identificationKey] as? CustomStringConvertible else {
            throw RKError.unidentifiable
        }
        
        return identifier
        
    }
    
}
