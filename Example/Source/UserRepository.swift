//
//  UserRepository.swift
//  Example
//
//  Created by Luciano Polit on 18/7/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import Foundation
import PromiseKit
import RepositoryKit

// MARK: - User repository (networking and storage)
class UserRepository: RKCRUDNetworkingStorageRepository, RKSynchronizer {
    
    // MARK: - Typealiases
    typealias Entity = User
    typealias StorageRepository = UserStorageRepository
    typealias NetworkingRepository = UserNetworkingRepository
    
    // MARK: - Properties
    var storage: StorageRepository
    var networking: NetworkingRepository
    
    var synchronizableAttribute: String {
        return "synchronized"
    }
    
    // MARK: - Initialization
    init(coreDataStack: RKCoreDataStack, networkingSession: RKNetworkingSession) {
        storage = StorageRepository(coreDataStack: coreDataStack)
        networking = UserNetworkingRepository(networkingSession: networkingSession)
    }
    
}

// MARK: - User repository (networking)
class UserNetworkingRepository: RKCRUDNetworkingRepository, RKDictionaryIdentifier {
    
    // MARK: - Typealiases
    typealias Entity = Dictionary<String, AnyObject>
    
    // MARK: - Properties
    var networking: RKNetworking
    
    var path: String = "users"
    
    var identificationKey: String {
        return "_id"
    }
    
    // MARK: - Initialization
    init(networkingSession: RKNetworkingSession) {
        self.networking = networkingSession
    }
    
}

// MARK: - User repository (storage)
class UserStorageRepository: RKCRUDStorageRepository {
    
    // MARK: - Typealiases
    typealias Entity = User
    
    // MARK: - Properties
    var storage: RKStorage
    
    var name: String = "User"
    
    // MARK: - Initialization
    init(coreDataStack: RKCoreDataStack) {
        self.storage = coreDataStack
    }
    
}