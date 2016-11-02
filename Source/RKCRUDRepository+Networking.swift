//
//  RKCRUDRepository+Networking.swift
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

// The repository is a *CRUD Networking Repository* and the entity is a *Networking Entity*.
extension RKCRUDRepository where Self: RKCRUDNetworkingRepository, Entity: RKNetworkingEntity {
    
    // MARK: - Create
    /**
     Makes a request to the `Networking` with the purpouse of create a new `Entity`.
     
     - Parameter entity: A `Dictionary` that is used to create the new `Entity` on the `Networking`.
     
     - Returns: A promise of `Entity`.
     */
    public func create(entity: Dictionary<String, AnyObject>) -> Promise<Entity> {
        
        return networking.request(.POST, path: "\(path)", parameters: entity)
            .then { dictionary in
                RKDictionaryTransformer.merge(entity, new: dictionary)
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
            .then { dictionary in
                RKDictionaryTransformer.merge(entity.dictionary, new: dictionary)
            }
            .then { dictionary in
                self.update(entity, withDictionary: dictionary)
            }
        
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
    public func initialization(dictionary: Dictionary<String, AnyObject>) -> Promise<Entity> {
        
        return Promise { success, failure in
            guard let entity = Entity(dictionary: dictionary) else {
                failure(RKError.initialization)
                return
            }
            
            success(entity)
        }
        
    }
    
    /// Initializes an `Array` of `Entity` with the specific `Array` of `Dictionary`.
    public func initialization(array: [Dictionary<String, AnyObject>]) -> Promise<[Entity]> {
        
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
    
    /// Updates an `Entity` with the specific `Dictionary`.
    /// If it is dictionary updateable, call update method (it should be a class).
    /// If it is not a dictionary, initialize a new one (it should be a struct).
    internal func update(entity: Entity, withDictionary dictionary: Dictionary<String, AnyObject>) -> Promise<Entity> {
        
        if let updateableEntity = entity as? RKDictionaryUpdateable {
            return Promise { success, failure in
                updateableEntity.update(dictionary)
                success(entity)
            }
        } else {
            return initialization(dictionary)
        }
        
    }
    
}