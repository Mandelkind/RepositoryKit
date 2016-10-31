//
//  RKCRUDRepository.swift
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

/// It is needed to be considered a *CRUDRepository* and includes **C**reate, **R**ead, **U**pdate and **D**elete methods.
public protocol RKCRUDRepository: RKRepository {
    
    // MARK: - Create
    /**
     Creates an entity in the repository.
     
     - Parameter entity: A `Dictionary` that will initialize the `Entity` object.
     
     - Returns: A promise of the `Entity` created.
     */
    func create(entity: Dictionary<String, AnyObject>) -> Promise<Entity>
    
    // MARK: - Read
    /**
     Searches all entities in the repository.
     
     - Returns: A promise of an `Array` of `Entity`.
     */
    func search() -> Promise<[Entity]>
    
    // MARK: - Update
    /**
     Updates an entity in the repository.
     
     - Parameter entity: A reference of the entity to be updated.
     
     - Returns: A promise of the `Entity` updated.
     */
    func update(entity: Entity) -> Promise<Entity>
    
    // MARK: - Delete
    /**
     Deletes an entity in the repository.
     
     - Parameter entity: A reference of the entity to be deleted.
     
     - Returns: A promise of `Void`.
     */
    func delete(entity: Entity) -> Promise<Void>
    
}

// MARK: - Utils
extension RKCRUDRepository {
    
    internal typealias DictionaryEntity = Dictionary<String, AnyObject>
    
    internal func merge(old: DictionaryEntity, new: DictionaryEntity) -> Promise<DictionaryEntity> {
        
        return Promise { success, failure in
            
            var dictionary = old
            
            for (key, value) in new {
                dictionary[key] = value
            }
            
            success(dictionary)
            
        }
        
    }
    
}