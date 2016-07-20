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

class UserRepository: RKCRUDNetworkingStorageRepository, RKStorageSynchronizer {
    
    typealias Entity = User
    typealias StorageRepository = UserStorageRepository
    typealias NetworkingRepository = UserNetworkingRepository
    
    var storage: StorageRepository
    var networking: NetworkingRepository
    
    var updateableAttribute: String {
        return "synchronized"
    }
    
    init(coreDataStack: CoreDataStack, networkingSession: NetworkingSession) {
        storage = StorageRepository(coreDataStack: coreDataStack)
        networking = UserNetworkingRepository(networkingSession: networkingSession)
    }
    
}

class UserNetworkingRepository: RKCRUDNetworkingRepository, RKDictionaryIdentifier {
    
    typealias Entity = Dictionary<String, AnyObject>
    
    var networking: RKNetworking
    
    var url: String = "http://localhost:3000/users"
    
    var identificationKey: String {
        return "_id"
    }
    
    init(networkingSession: NetworkingSession) {
        self.networking = networkingSession
    }
    
}

class UserStorageRepository: RKCRUDStorageRepository {
    
    typealias Entity = User
    
    var storage: RKStorage
    
    var name: String = "User"
    
    init(coreDataStack: CoreDataStack) {
        self.storage = coreDataStack
    }
    
}