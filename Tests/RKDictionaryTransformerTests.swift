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
        
        let firstDict: DictionaryEntity = [
            "firstName": "Luciano",
            "lastName": "Polit"
        ]
        let secondDict: DictionaryEntity = [
            "firstName": "Lucho",
            "_id": "q1w2e3"
        ]
        
        let expectedMerge: DictionaryEntity = [
            "firstName": "Lucho",
            "lastName": "Polit",
            "_id": "q1w2e3"
        ]
        
        let merged = DictionaryTransformer.merge(old: firstDict, new: secondDict)
        
        XCTAssertTrue(DictionaryTransformer.difference(old: expectedMerge, new: merged).isEmpty)
        
    }
    
    func testDifference() {
        
        let firstDictionary: DictionaryEntity = [
            "firstName": "Luciano",
            "lastName": "Polit",
            "age": 21,
            "owner": ["123", "234", "345"],
            "object": [
                "a": 123,
                "b": 456
            ]
        ]
        let secondDictionary: DictionaryEntity = [
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
        
        let expectedDifference: DictionaryEntity = [
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
        
        let difference = DictionaryTransformer.difference(old: firstDictionary, new: secondDictionary)
        
        XCTAssertTrue(DictionaryTransformer.difference(old: expectedDifference, new: difference).isEmpty)
        
    }
    
}
