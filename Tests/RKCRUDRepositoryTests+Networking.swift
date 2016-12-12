//
//  RKCRUDRepositoryTests+Networking.swift
//  Example
//
//  Created by Luciano Polit on 6/12/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import XCTest
import RepositoryKit

// MARK: - Main
class RKCRUDNetworkingRepositoryTests: XCTestCase {
    
    // MARK: - Constants
    let validTestCase = Message(dictionary: [
        "text": "Here goes a cool message!",
        "_id": "asd123"
        ])!
    
    // MARK: - Properties
    var networkingSession: FakeNetworkingSession!
    var repository: MessageRepository!
    
    // MARK: - Set up
    override func setUp() {
        super.setUp()
        networkingSession = FakeNetworkingSession()
        repository = MessageRepository(store: networkingSession)
    }
    
}

// MARK: - Requests
extension RKCRUDNetworkingRepositoryTests {
    
    // MARK: - Create
    func testCreateRequest() {
        
        let exp = expectation(description: "Expected to verify the create request")
        
        repository.create(validTestCase.dictionary)
            .always {
                XCTAssertEqual(self.networkingSession.lastPath, self.repository.path)
                XCTAssertEqual(self.networkingSession.lastMethod, .POST)
                exp.fulfill()
            }
            .catch(execute: voidFailure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    // MARK: - Read
    func testSearchRequest() {
        
        let exp = expectation(description: "Expected to verify the search request")
        
        repository.search()
            .always {
                XCTAssertEqual(self.networkingSession.lastPath, self.repository.path)
                XCTAssertEqual(self.networkingSession.lastMethod, .GET)
                exp.fulfill()
            }
            .catch(execute: voidFailure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testSearchByIDRequest() {
        
        let exp = expectation(description: "Expected to verify the search by id request")
        
        repository.search(validTestCase.id)
            .always {
                XCTAssertEqual(self.networkingSession.lastPath, "\(self.repository.path)/\(self.validTestCase.id)")
                XCTAssertEqual(self.networkingSession.lastMethod, .GET)
                exp.fulfill()
            }
            .catch(execute: voidFailure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    // MARK: - Update
    func testUpdateRequest() {
        
        let exp = expectation(description: "Expected to verify the update request")
        
        repository.update(validTestCase)
            .always {
                XCTAssertEqual(self.networkingSession.lastPath, "\(self.repository.path)/\(self.validTestCase.id)")
                XCTAssertEqual(self.networkingSession.lastMethod, .PUT)
                exp.fulfill()
            }
            .catch(execute: voidFailure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    // MARK: - Delete
    func testDeleteRequest() {
        
        let exp = expectation(description: "Expected to verify the delete request")
        
        repository.delete(validTestCase)
            .always {
                XCTAssertEqual(self.networkingSession.lastPath, "\(self.repository.path)/\(self.validTestCase.id)")
                XCTAssertEqual(self.networkingSession.lastMethod, .DELETE)
                exp.fulfill()
            }
            .catch(execute: voidFailure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
}

// MARK: - Operations
extension RKCRUDNetworkingRepositoryTests {
    
    // MARK: - Create
    func testCreateSuccess() {
        
        let exp = expectation(description: "Expected to create a message")
        
        let answer: Dictionary<String, Any> = [
            "_id": "qwe123",
            "date": 1481071880
        ]
        
        networkingSession.answer = answer
        
        repository.create(validTestCase.dictionary)
            .then { message -> Void in
                XCTAssertEqual(message.text, self.validTestCase.text)
                XCTAssertEqual(message.id, answer["_id"] as? String)
                XCTAssertEqual(message.date?.timeIntervalSince1970, TimeInterval(answer["date"] as! Int))
            }
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testCreateFailure() {
        
        let exp = expectation(description: "Expected to fail when attempting to create a message")
        
        networkingSession.answer = [:]
        
        repository.create(["text": 123123])
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
        
        let exp = expectation(description: "Expected to search all the messages")
        
        let answer: Array<Dictionary<String, Any>> = [
            ["_id": "aaa111", "text": "Here goes the first text!"],
            ["_id": "qqq222", "text": "Here goes the second text!", "date": 1481071880]
        ]
        
        networkingSession.answer = answer
        
        repository.search()
            .then { messages -> Void in
                XCTAssertEqual(messages[0].id, answer[0]["_id"] as? String)
                XCTAssertEqual(messages[0].text, answer[0]["text"] as? String)
                XCTAssertEqual(messages[1].id, answer[1]["_id"] as? String)
                XCTAssertEqual(messages[1].text, answer[1]["text"] as? String)
                XCTAssertEqual(messages[1].date?.timeIntervalSince1970, TimeInterval(answer[1]["date"] as! Int))
            }
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testSearchByID() {
        
        let exp = expectation(description: "Expected to search a message with the specified ID")
        
        let answer: Dictionary<String, Any> = ["_id": "aaa111", "text": "Here goes the first text!"]
        
        networkingSession.answer = answer
        
        repository.search("aaa111")
            .then { message -> Void in
                XCTAssertEqual(message.id, answer["_id"] as? String)
                XCTAssertEqual(message.text, answer["text"] as? String)
            }
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    // MARK: - Update
    func testUpdate() {
        
        let exp = expectation(description: "Expected to update a message")
        
        let text = "Another text here!"
        let date = 1481071880
        
        networkingSession.answer = ["date": date]
        
        var msg = validTestCase
        msg.text = text
        
        repository.update(msg)
            .then { message -> Void in
                XCTAssertEqual(message.date?.timeIntervalSince1970, TimeInterval(date))
                XCTAssertEqual(message.text, text)
            }
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    // MARK: - Delete
    func testDelete() {
        
        let exp = expectation(description: "Expected to delete a message")
        
        networkingSession.answer = [:]
        
        repository.delete(validTestCase)
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
}
