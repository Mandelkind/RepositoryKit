//
//  RKPatchableRepositoryTests+NetworkingStorage.swift
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
class RKPatchableNetworkingStorageRepositoryTests: XCTestCase {
    
    // MARK: - Constants
    let validTestCase = [
        "_id": "a1s2d3",
        "firstName": "Luciano",
        "lastName": "Polit"
    ]
    
    // MARK: - Properties
    var networkingSession: FakeNetworkingSession!
    var coreDataStack: FakeCoreDataStack!
    var repository: UserRepository!
    var createPromise: Promise<User>!
    
    // MARK: - Set up
    override func setUp() {
        super.setUp()
        try! coreDataStack = FakeCoreDataStack(modelName: "Model")
        networkingSession = FakeNetworkingSession()
        repository = UserRepository(coreDataStack: coreDataStack, networkingSession: networkingSession)
        networkingSession.answer = [:]
        createPromise = repository.create(validTestCase)
    }
    
}

// MARK: - Requests
extension RKPatchableNetworkingStorageRepositoryTests {
    
    func testPatchRequest() {
        
        let exp = expectation(description: "Expected to verify the patch request")
        
        let name = "Lucho"
        
        createPromise
            .then { user -> User in
                user.firstName = name
                return user
            }
            .then(execute: repository.patch)
            .then { user -> Void in
                XCTAssertEqual(self.networkingSession.lastPath, "\(self.repository.networking.path)/\(self.validTestCase["_id"]!)")
                XCTAssertEqual(self.networkingSession.lastMethod, .PATCH)
                XCTAssertEqual(self.networkingSession.lastParameters?.count, 1)
                XCTAssertEqual(self.networkingSession.lastParameters?["firstName"] as? String, name)
            }
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
}

// MARK: - Operations
extension RKPatchableNetworkingStorageRepositoryTests {
    
    func testPatch() {
        
        let exp = expectation(description: "Expected to patch a user")
        
        let name = "Another"
        
        createPromise
            .then { user -> User in
                user.firstName = name
                return user
            }
            .then(execute: repository.patch)
            .then { user -> Void in
                XCTAssertEqual(user.firstName, name)
            }
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testEmptyPatch() {
        
        let exp = expectation(description: "Expected to patch a user without making any request because the difference is empty")
        
        createPromise
            .then { user -> User in
                self.networkingSession.lastPath = nil
                self.networkingSession.lastMethod = nil
                self.networkingSession.lastParameters = nil
                return user
            }
            .then(execute: repository.patch)
            .then { _ -> Void in
                XCTAssertNil(self.networkingSession.lastPath)
                XCTAssertNil(self.networkingSession.lastMethod)
                XCTAssertNil(self.networkingSession.lastParameters)
            }
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
}
