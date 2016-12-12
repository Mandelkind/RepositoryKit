//
//  RKCRUDRepositoryTests+Storage.swift
//  Example
//
//  Created by Luciano Polit on 6/12/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

@testable import Example
import XCTest
import CoreData
import RepositoryKit
import PromiseKit

// MARK: - Main
class RKCRUDStorageRepositoryTests: XCTestCase {
    
    // MARK: - Constants
    let validTestCase = [
        "firstName": "Luciano",
        "lastName": "Polit"
    ]
    
    // MARK: - Properties
    var coreDataStack: FakeCoreDataStack!
    var repository: UserStorageRepository!
    var createPromise: Promise<User>!
    
    // MARK: - Set up
    override func setUp() {
        super.setUp()
        try! coreDataStack = FakeCoreDataStack(modelName: "Model")
        repository = UserStorageRepository(store: coreDataStack)
        createPromise = repository.create(validTestCase)
    }
    
}

// MARK: - Operations
extension RKCRUDStorageRepositoryTests {

    // MARK: - Create
    func testCreateSuccess() {
        
        let exp = expectation(description: "Expected to create a user")
        
        createPromise
            .then { user -> Void in
                XCTAssertEqual(user.firstName, self.validTestCase["firstName"])
                XCTAssertEqual(user.lastName, self.validTestCase["lastName"])
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
                XCTAssertEqual(error.localizedDescription, RKError.initialization.localizedDescription)
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
        
        let name = "Lucho"
        
        createPromise
            .then { user -> User in
                user.firstName = name
                return user
            }
            .then(execute: repository.update)
            .then { user -> Void in
                XCTAssertEqual(user.firstName, name)
                XCTAssertEqual(user.lastName, self.validTestCase["lastName"])
            }
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    // MARK: - Delete
    func testDelete() {
        
        let exp = expectation(description: "Expected to create a user and delete it")
        
        var objectID: NSManagedObjectID!
        
        repository.create(validTestCase)
            .then { user -> User in
                objectID = user.objectID
                return user
            }
            .then(execute: repository.delete)
            .then { _ in
                self.repository.search(NSPredicate(format: "self == %@", objectID))
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
    
    // MARK: - Massive
    func testMassiveOperations() {
        
        let exp = expectation(description: "Expected to create, update and delete multiple users")
        
        var users = [Dictionary<String, Any>]()
        
        for _ in 0...200 {
            users.append(validTestCase)
        }
        
        repository.create(users)
            .then { _ in
                self.repository.search()
            }
            .then { users -> [User] in
                return users.map { user in
                    user.firstName = "\(user.firstName) - Edited"
                    return user
                }
            }
            .then(execute: repository.update)
            .then { users in
                self.repository.delete(users)
            }
            .then { _ in
                self.repository.search()
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
