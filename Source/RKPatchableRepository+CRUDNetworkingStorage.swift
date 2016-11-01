//
//  RKPatchableRepository+CRUDNetworkingStorage.swift
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

extension RKPatchableRepository where Self: RKCRUDNetworkingStorageRepository,
    Self.Entity: NSManagedObject, Self.Entity: RKNetworkingStorageEntity, Self.Entity: RKPatchable,
    Self.NetworkingRepository: RKCRUDNetworkingDictionaryRepository,
    Self.NetworkingRepository.Entity == RKDictionaryEntity,
    Self.StorageRepository: RKCRUDStorageRepository,
    Self.StorageRepository.Entity == Self.Entity {
    
    public func patch(entity: Entity) -> Promise<Entity> {
        
        let difference = RKDictionaryTransformer.difference(entity.dictionaryMemory, new: entity.dictionary)
        
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
    
}