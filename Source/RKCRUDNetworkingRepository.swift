//
//  RKCRUDNetworkingRepository.swift
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

/// It is needed by a `Repository` to manage a `Networking`.
public protocol RKCRUDNetworkingRepository: RKNetworkingRepository, RKCRUDRepository { }

// MARK: - Entity is not a dictionary
extension RKCRUDNetworkingRepository where Entity: Identifiable, Entity: DictionaryRepresentable, Entity: DictionaryInitializable {
    
    // MARK: - Create
    /**
     Makes a request to the `Networking` with the purpouse of create a new `Entity`.
     
     - Parameter entity: A `Dictionary` that is used to create the new `Entity` on the `Networking`.
     
     - Returns: A promise of `Entity`.
     */
    public func create(entity: Dictionary<String, AnyObject>) -> Promise<Entity> {
        
        return networking.request(.POST, path: "\(path)", parameters: entity)
            .then { dictionary in
                self.merge(entity, new: dictionary)
            }
            .then(initialization)
        
    }
    
    // MARK: - Read
    /**
     Makes a request to the `Networking` with the purpouse of find an `Entity` with a specified unique identifier.
     
     - Parameter identifier: A `CustomStringConvertible` that is used to identify the `Entity`.
     
     - Returns: A promise of `Entity`.
     */
    public func search(identifier: CustomStringConvertible) -> Promise<Entity> {
        
        return networking.request(.GET, path: "\(path)/\(identifier)")
            .then(initialization)
        
    }
    
    /**
     Makes a request to the `Networking` with the purpouse of find all the entities.
     
     - Returns: A promise of an `Array` of `Entity`.
     */
    public func search() -> Promise<[Entity]> {
        
        return networking.request(.GET, path: "\(path)")
            .then(initialization)
        
    }
    
    // MARK: - Update
    /**
     Makes a request to the `Networking` with the purpouse of update an `Entity` with a specific unique identifier.
     
     - Parameter entity: The entity that needs to be updated.
     
     - Returns: A promise of `Entity`.
     */
    public func update(entity: Entity) -> Promise<Entity> {
        
        return networking.request(.PUT, path: "\(path)/\(entity.id)", parameters: entity.dictionary)
            .then { entity }
        
    }
    
    // MARK: - Delete
    /**
     Makes a request to the `Networking` with the purpouse of delete an `Entity` with a specific unique identifier.
     
     - Parameter entity: The entity that needs to be deleted.
     
     - Returns: A promise of `Void`.
     */
    public func delete(entity: Entity) -> Promise<Void> {
        
        return networking.request(.DELETE, path: "\(path)/\(entity.id)")
        
    }
    
    // MARK: - Utils
    /// Initializes an `Entity` with the specific `Dictionary`.
    public func initialization(dictionary: DictionaryEntity) -> Promise<Entity> {
        
        return Promise { success, failure in
            guard let entity = Entity(dictionary: dictionary) else {
                failure(RKError.initialization)
                return
            }
            
            success(entity)
        }
        
    }
    
    /// Initializes an `Array` of `Entity` with the specific `Array` of `Dictionary`.
    public func initialization(array: [DictionaryEntity]) -> Promise<[Entity]> {
        
        return Promise { success, failure in
            var entities = [Entity]()
            
            for dictionary in array {
                if let entity = Entity(dictionary: dictionary) {
                    entities.append(entity)
                }
            }
            
            success(entities)
        }
        
    }
    
}

// MARK: - Entity is a dictionary
extension RKCRUDNetworkingRepository where Self: RKDictionaryIdentifier, Entity == Dictionary<String, AnyObject> {
    
    // MARK: - Create
    /**
     Makes a request to the `Networking` with the purpouse of create a new `Entity`.
     
     - Parameter entity: A `Dictionary` that is used to create the new `Entity` on the `Networking`.
     
     - Returns: A promise of `Entity`.
     */
    public func create(entity: Dictionary<String, AnyObject>) -> Promise<Entity> {
        
        return networking.request(.POST, path: "\(path)", parameters: entity)
            .then { dictionary in
                self.merge(entity, new: dictionary)
            }
        
    }
    
    // MARK: - Read
    /**
     Makes a request to the `Networking` with the purpouse of find an `Entity` with a specified unique identifier.
     
     - Parameter identifier: A `CustomStringConvertible` that is used to identify the `Entity`.
     
     - Returns: A promise of `Entity`.
     */
    public func search(identifier: CustomStringConvertible) -> Promise<Entity> {
        
        return networking.request(.GET, path: "\(path)/\(identifier)")
        
    }
    
    /**
     Makes a request to the `Networking` with the purpouse of find all the entities.
     
     - Returns: A promise of an `Array` of `Entity`.
     */
    public func search() -> Promise<[Entity]> {
        
        return networking.request(.GET, path: "\(path)")
        
    }
    
    // MARK: - Update
    /**
     Makes a request to the `Networking` with the purpouse of update an `Entity` with a specific unique identifier.
     
     - Parameter entity: The entity that needs to be updated.
     
     - Returns: A promise of `Entity`.
     */
    public func update(entity: Entity) -> Promise<Entity> {
        
        return entityIdentifiable(entity)
            .then { identifier in
                self.networking.request(.PUT, path: "\(self.path)/\(identifier)", parameters: entity)
            }
            .then { entity }
        
    }
    
    // MARK: - Delete
    /**
     Makes a request to the `Networking` with the purpouse of delete an `Entity` with a specific unique identifier.
     
     - Parameter entity: The entity that needs to be deleted.
     
     - Returns: A promise of `Void`.
     */
    public func delete(entity: Entity) -> Promise<Void> {
        
        return entityIdentifiable(entity)
            .then { identifier in
                self.networking.request(.DELETE, path: "\(self.path)/\(identifier)")
            }
        
    }
    
    // MARK: - Utils
    private func entityIdentifiable(entity: Entity) -> Promise<CustomStringConvertible> {
        
        return Promise { success, failure in
            
            guard let identifier = entity[identificationKey] as? CustomStringConvertible else {
                failure(RKError.unidentifiable)
                return
            }
            
            success(identifier)
            
        }
        
    }
    
}

// MARK: - Utils
extension RKCRUDNetworkingRepository {
    
    /// Typealias that represent an `Entity` of the type `Dictionary`.
    public typealias DictionaryEntity = Dictionary<String, AnyObject>
    
    private func merge(old: DictionaryEntity, new: DictionaryEntity) -> Promise<DictionaryEntity> {
        
        return Promise { success, failure in
            
            var dictionary = old
            
            for (key, value) in new {
                dictionary[key] = value
            }
            
            success(dictionary)
            
        }
        
    }
    
}