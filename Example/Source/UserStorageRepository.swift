//
//  UserStorageRepository.swift
//  Example
//
//  Created by Luciano Polit on 3/11/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import RepositoryKit

// MARK: - User repository (storage)
/*
 It needs to conform:
    - RKCRUDStorageRepository: it is needed to manage CRUD operations on the local storage.
 */
class UserStorageRepository: RKCRUDStorageRepository {
    
    // MARK: - Typealiases
    typealias Entity = User
    
    // MARK: - Properties
    // The data store.
    var store: RKStorage
    // The name that is used to identify the entity.
    var name: String = "User"
    
    // MARK: - Initialization
    init(store: RKStorage) {
        self.store = store
    }
    
}
