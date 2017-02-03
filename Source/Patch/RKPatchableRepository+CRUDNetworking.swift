//
//  RKPatchableRepository+CRUDNetworking.swift
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

// The repository is a *CRUD Networking Patchable Repository* and the entity is a *Networking Patchable Entity*.
extension RKPatchableRepository where Self: RKCRUDNetworkingRepository, Entity: RKNetworkingEntity, Entity: RKPatchable {
    
    // MARK: - Patch
    /**
     Updates an entity in the repository without sending unnecessary data, just the modified fields. It is a partial update.
     
     - Parameter entity: A reference of the entity to be updated.
     
     - Returns: A promise of the `Entity` updated.
     */
    public func patch(_ entity: Entity) -> Promise<Entity> {
        
        let difference = RKDictionaryTransformer.difference(old: entity.dictionaryMemory, new: entity.dictionary)
        
        if difference.isEmpty {
            return Promise(value: entity)
        }
        
        return store.request(method: .PATCH, path: "\(path)/\(entity.id)", parameters: difference)
            .then { dictionary in
                RKDictionaryTransformer.merge(old: entity.dictionary, new: dictionary)
            }
            .then { dictionary in
                self.update(entity: entity, withDictionary: dictionary)
        }
        
    }
    
}
