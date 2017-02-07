//
//  RKSynchronizableRepositoryTests+CRUDNetworkingStorage.swift
//  Example
//
//  Created by Luciano Polit on 8/12/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

@testable import Example
import XCTest
import CoreData
import RepositoryKit
import PromiseKit

// MARK: - Main
class RKSynchronizableNetworkingStorageRepositoryTests: XCTestCase {
    
    // MARK: - Constants
    let users = [
        ["firstName": "firstFN", "lastName": "firstLN", "_id": "firstID"],
        ["firstName": "secondFN", "lastName": "secondLN"],
        ["firstName": "thirdFN", "lastName": "thirdLN"]
    ]
    
    // MARK: - Properties
    var networkingSession: FakeNetworkingSession!
    var coreDataStack: FakeCoreDataStack!
    var repository: UserRepository!
    var createPromise: Promise<Void>!
    
    // MARK: - Set up
    override func setUp() {
        super.setUp()
        try! coreDataStack = FakeCoreDataStack(modelName: "Model")
        networkingSession = FakeNetworkingSession()
        repository = UserRepository(coreDataStack: coreDataStack, networkingSession: networkingSession)
        setUpSynchronizePromise()
    }
    
    func setUpSynchronizePromise() {
        
        var promises = [Promise<User>]()
        
        for user in users {
            promises.append(repository.storage.create(user))
        }
        
        networkingSession.answer = [:]
        
        createPromise =
            when(fulfilled: promises)
                .then { _ -> Void in }
        
    }
    
}

// MARK: - Requests
extension RKSynchronizableNetworkingStorageRepositoryTests {
    
    func testSynchronizeStorageToNetworkingRequest() {
        
        let exp = expectation(description: "Expected to verify the synchronize from storage to networking request")
        
        createPromise
            .then { _ -> Void in
                self.networkingSession.callback = nil
                self.networkingSession.answer = nil
            }
            .then(execute: repository.synchronizeStorageToNetworking)
            .always {
                XCTAssertEqual(self.networkingSession.lastMethod, .POST)
                XCTAssertEqual(self.networkingSession.lastPath, "\(self.repository.networking.path)/collection")
                exp.fulfill()
            }
            .catch(execute: voidFailure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testSynchronizeNetworkingToStorageRequest() {
        
        let exp = expectation(description: "Expected to verify the synchronize from networking to storage request")
        
        createPromise
            .then { _ -> Void in
                self.networkingSession.callback = nil
                self.networkingSession.answer = nil
            }
            .then(execute: repository.networking.search)
            .then(execute: repository.synchronizeNetworkingToStorage)
            .always {
                XCTAssertEqual(self.networkingSession.lastMethod, .GET)
                XCTAssertEqual(self.networkingSession.lastPath, self.repository.networking.path)
                exp.fulfill()
            }
            .catch(execute: voidFailure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
}

// MARK: - Operations
extension RKSynchronizableNetworkingStorageRepositoryTests {
    
    func testSynchronize() {
        
        let exp = expectation(description: "Expected to synchronize both repositories")
        
        createPromise
            .then {
                self.networkingSession.callback = self.networkingSessionCallback
            }
            .then(execute: repository.synchronize)
            .then(execute: repository.search)
            .then { users -> Void in
                XCTAssertEqual(users.count, 3)
            }
            .then {
                self.repository.storage.search(NSPredicate(format: "id == 'firstID'"))
            }
            .then { users -> Void in
                XCTAssertEqual(users[0].firstName, "Luciano")
                XCTAssertEqual(users[0].lastName, "Polit")
            }
            .then {
                self.repository.storage.search(NSPredicate(format: "id == 'thirdID'"))
            }
            .then { users -> Void in
                XCTAssertEqual(users.count, 0)
            }
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
}

// MARK: - Util
extension RKSynchronizableNetworkingStorageRepositoryTests {
    
    func networkingSessionCallback() {
        
        if networkingSession.lastMethod == .GET {
            
            var allUsers = users
            allUsers[0]["firstName"] = "Luciano"
            allUsers[0]["lastName"] = "Polit"
            allUsers[1]["_id"] = "secondID"
            allUsers.remove(at: 2)
            allUsers.append([
                "firstName": "fourthFN",
                "lastName": "fourthLN",
                "_id": "fourthID"
                ])
            
            networkingSession.answer = allUsers
            
        }
        
        if networkingSession.lastMethod == .POST {
            
            networkingSession.answer = [
                ["_id": "secondID"],
                ["_id": "thirdID"]
            ]
            
        }
        
    }
    
}
