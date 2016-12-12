//
//  RKDictionaryTransformerTests.swift
//  Example
//
//  Created by Luciano Polit on 8/12/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import XCTest
import RepositoryKit

class RKDictionaryTransformerTests: XCTestCase {
    
    func testMerge() {
        
        let firstDict: RKDictionaryEntity = [
            "firstName": "Luciano",
            "lastName": "Polit"
        ]
        let secondDict: RKDictionaryEntity = [
            "firstName": "Lucho",
            "_id": "q1w2e3"
        ]
        
        let expectedMerge: RKDictionaryEntity = [
            "firstName": "Lucho",
            "lastName": "Polit",
            "_id": "q1w2e3"
        ]
        
        let merged = RKDictionaryTransformer.merge(old: firstDict, new: secondDict)
        
        XCTAssertTrue(RKDictionaryTransformer.difference(old: expectedMerge, new: merged).isEmpty)
        
    }
    
    func testDifference() {
        
        let firstDictionary: RKDictionaryEntity = [
            "firstName": "Luciano",
            "lastName": "Polit",
            "age": 21,
            "owner": ["123", "234", "345"],
            "object": [
                "a": 123,
                "b": 456
            ]
        ]
        let secondDictionary: RKDictionaryEntity = [
            "firstName": "Lucho",
            "lastName": "Polit",
            "owner": ["567", "678", "789"],
            "_id": "q1w2e3",
            "object": [
                "a": 123,
                "c": 789
            ],
            "anotherObject": [
                "other": "qaz"
            ]
        ]
        
        let expectedDifference: RKDictionaryEntity = [
            "firstName": "Lucho",
            "age": NSNull(),
            "_id": "q1w2e3",
            "object": [
                "b": NSNull(),
                "c": 789
            ],
            "anotherObject": [
                "other": "qaz"
            ]
        ]
        
        let difference = RKDictionaryTransformer.difference(old: firstDictionary, new: secondDictionary)
        
        XCTAssertTrue(RKDictionaryTransformer.difference(old: expectedDifference, new: difference).isEmpty)
        
    }
    
}
