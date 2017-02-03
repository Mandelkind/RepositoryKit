//
//  RKCRUDRepositoryTests+NetworkingStorage.swift
//  Example
//
//  Created by Luciano Polit on 7/12/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

@testable import Example
import XCTest
import CoreData
import RepositoryKit
import PromiseKit

// MARK: - Main
class RKCRUDNetworkingStorageRepositoryTests: XCTestCase {
    
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
        networkingSession.answer = ["_id": "123123"]
        createPromise =
            repository.create(validTestCase)
                .then { user -> User in
                    self.networkingSession.answer = [:]
                    return user
                }
    }
    
}

// MARK: - Requests
extension RKCRUDNetworkingStorageRepositoryTests {
    
    // MARK: - Create
    func testCreateRequest() {
        
        let exp = expectation(description: "Expected to verify the create request")
        
        repository.networking.create(validTestCase)
            .always {
                XCTAssertEqual(self.networkingSession.lastPath, self.repository.networking.path)
                XCTAssertEqual(self.networkingSession.lastMethod, .POST)
                exp.fulfill()
            }
            .catch(execute: voidFailure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    // MARK: - Read
    func testSearchRequest() {
        
        let exp = expectation(description: "Expected to verify the search request")
        
        repository.networking.search()
            .always {
                XCTAssertEqual(self.networkingSession.lastPath, self.repository.networking.path)
                XCTAssertEqual(self.networkingSession.lastMethod, .GET)
                exp.fulfill()
            }
            .catch(execute: voidFailure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testSearchByIDRequest() {
        
        let exp = expectation(description: "Expected to verify the search by id request")
        
        repository.networking.search(validTestCase["_id"]!)
            .always {
                XCTAssertEqual(self.networkingSession.lastPath, "\(self.repository.networking.path)/\(self.validTestCase["_id"]!)")
                XCTAssertEqual(self.networkingSession.lastMethod, .GET)
                exp.fulfill()
            }
            .catch(execute: voidFailure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    // MARK: - Update
    func testUpdateRequest() {
        
        let exp = expectation(description: "Expected to verify the update request")
        
        repository.networking.update(validTestCase)
            .always {
                XCTAssertEqual(self.networkingSession.lastPath, "\(self.repository.networking.path)/\(self.validTestCase["_id"]!)")
                XCTAssertEqual(self.networkingSession.lastMethod, .PUT)
                exp.fulfill()
            }
            .catch(execute: voidFailure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    // MARK: - Delete
    func testDeleteRequest() {
        
        let exp = expectation(description: "Expected to verify the delete request")
        
        repository.networking.delete(validTestCase)
            .always {
                XCTAssertEqual(self.networkingSession.lastPath, "\(self.repository.networking.path)/\(self.validTestCase["_id"]!)")
                XCTAssertEqual(self.networkingSession.lastMethod, .DELETE)
                exp.fulfill()
            }
            .catch(execute: voidFailure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
}

// MARK: - Operations
extension RKCRUDNetworkingStorageRepositoryTests {
    
    // MARK: - Create
    func testCreateSuccess() {
        
        let exp = expectation(description: "Expected to create a user")
        
        createPromise
            .then { user -> Void in
                XCTAssertEqual(user.firstName, self.validTestCase["firstName"])
                XCTAssertEqual(user.lastName, self.validTestCase["lastName"])
                XCTAssertEqual(user.id, "123123")
            }
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testCreateFailure() {
        
        let exp = expectation(description: "Expected to fail when attempting to create a user")
        
        repository.create(["firstName": "Luciano", "lastName": 1995])
            .then(execute: forceFailure)
            .always {
                exp.fulfill()
            }
            .catch { error in
                XCTAssertEqual(error.localizedDescription, RKError.parsing.localizedDescription)
            }
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    // MARK: - Read
    func testSearch() {
        
        let exp = expectation(description: "Expected to search all the created users")
        
        createPromise
            .then { _ in
                self.repository.search()
            }
            .then { users -> Void in
                for user in users {
                    XCTAssertNotNil(user.firstName)
                    XCTAssertNotNil(user.lastName)
                }
            }
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    // MARK: - Update
    func testUpdate() {
        
        let exp = expectation(description: "Expected to update a user created previously")
        
        createPromise
            .then { user -> User in
                user.firstName = "Lucho"
                return user
            }
            .then(execute: repository.update)
            .then { user -> Void in
                XCTAssertEqual(user.firstName, "Lucho")
                XCTAssertEqual(user.lastName, "Polit")
            }
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    // MARK: - Delete
    func testDeleteSuccess() {
        
        let exp = expectation(description: "Expected to create a user and delete it")
        
        var objectID: NSManagedObjectID!
        
        repository.create(validTestCase)
            .then { user -> User in
                objectID = user.objectID
                return user
            }
            .then(execute: repository.delete)
            .then { _ in
                self.repository.storage.search(NSPredicate(format: "self == %@", objectID))
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
    
    func testDeleteFailure() {
        
        let exp = expectation(description: "Expected to fail when attempting to delete a user because it is unidentifiable")
        
        repository.networking.delete(["firstName": "Lucho", "lastName": "Polit", "id": "asd123"])
            .then(execute: forceFailure)
            .always {
                exp.fulfill()
            }
            .catch { error in
                XCTAssertEqual(error.localizedDescription, RKError.unidentifiable.localizedDescription)
            }
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
}
