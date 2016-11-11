//
//  UserRepository.swift
//  Example
//
//  Created by Luciano Polit on 18/7/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import RepositoryKit

// MARK: - User repository (networking and storage)
/*
 It needs to conform:
    - RKCRUDNetworkingStorageRepository: it is needed to manage CRUD operations with `Networking & Storage entities`.
    - RKSynchronizableRepository: it allows to synchronize both repositories.
    - RKPatchableRepository: it allows to make PATCH requests, updating partially the entity, avoiding sending a big amount of data.
 */
class UserRepository: RKCRUDNetworkingStorageRepository, RKSynchronizableRepository, RKPatchableRepository {
    
    // MARK: - Typealiases
    typealias Entity = User
    typealias StorageRepository = UserStorageRepository
    typealias NetworkingRepository = UserNetworkingRepository
    
    // MARK: - Properties
    var storage: StorageRepository
    var networking: NetworkingRepository
    
    // It needs to know about the entity attribute that represents if it is synchronized or not.
    var synchronizableAttribute: String {
        return "synchronized"
    }
    
    // MARK: - Initialization
    init(coreDataStack: RKCoreDataStack, networkingSession: RKNetworkingSession) {
        storage = StorageRepository(coreDataStack: coreDataStack)
        networking = UserNetworkingRepository(networkingSession: networkingSession)
    }
    
}
