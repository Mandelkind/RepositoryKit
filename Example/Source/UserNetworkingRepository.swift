//
//  UserNetworkingRepository.swift
//  Example
//
//  Created by Luciano Polit on 3/11/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import RepositoryKit

// MARK: - User repository (networking)
/*
 It needs to conform:
    - RKCRUDNetworkingRepository: it is needed to manage CRUD operations on the networking store.
    - RKDictionaryIdentifier: it is needed to be able to identify the entities with an id.
 */
class UserNetworkingRepository: RKCRUDNetworkingRepository, RKDictionaryIdentifier {
    
    // MARK: - Typealiases
    typealias Entity = Dictionary<String, AnyObject>
    
    // MARK: - Properties
    // The data store.
    var store: RKNetworking
    // The path which identifies the repository on the store.
    var path: String = "users"
    // The key that is used to identify the user on the dictionary.
    var identificationKey: String {
        return "_id"
    }
    
    // MARK: - Initialization
    init(networkingSession: RKNetworkingSession) {
        self.store = networkingSession
    }
    
}