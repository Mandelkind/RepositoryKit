//
//  RKPatchableRepositoryTests+Networking.swift
//  Example
//
//  Created by Luciano Polit on 8/12/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import XCTest
import RepositoryKit

// MARK: - Main
class RKPatchableNetworkingRepositoryTests: XCTestCase {
    
    // MARK: - Properties
    var networkingSession: FakeNetworkingSession!
    var repository: MessageRepository!
    var validTestCase = Message(dictionary: [
        "text": "Here goes a cool message!",
        "_id": "asd123"
        ])!
    
    // MARK: - Set up
    override func setUp() {
        super.setUp()
        networkingSession = FakeNetworkingSession()
        repository = MessageRepository(store: networkingSession)
    }
    
}

// MARK: - Requests
extension RKPatchableNetworkingRepositoryTests {
    
    func testPatchRequest() {
        
        let exp = expectation(description: "Expected to verify the patch request")
        
        let text = "New text!"
        
        validTestCase.text = text
        
        repository.patch(validTestCase)
            .always {
                XCTAssertEqual(self.networkingSession.lastPath, "\(self.repository.path)/\(self.validTestCase.id)")
                XCTAssertEqual(self.networkingSession.lastMethod, .PATCH)
                XCTAssertEqual(self.networkingSession.lastParameters?.count, 1)
                XCTAssertEqual(self.networkingSession.lastParameters?["text"] as? String, text)
                exp.fulfill()
            }
            .catch(execute: voidFailure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
}

// MARK: - Operations
extension RKPatchableNetworkingRepositoryTests {
    
    func testPatch() {
        
        let exp = expectation(description: "Expected to patch a message")
        
        let text = "Another text!"
        
        validTestCase.text = text
        
        networkingSession.answer = [:]
        
        repository.patch(validTestCase)
            .then { message -> Void in
                XCTAssertEqual(message.text, text)
            }
            .always {
                exp.fulfill()
            }
            .catch(execute: failure)
        
        waitForExpectations(timeout: 1, handler: nil)
        
    }
    
    func testEmptyPatch() {
        
        let exp = expectation(description: "Expected to patch a message without making any request because the difference is empty")
        
        networkingSession.lastPath = nil
        networkingSession.lastMethod = nil
        networkingSession.lastParameters = nil
        
        repository.patch(validTestCase)
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
