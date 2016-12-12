//
//  FakeMessage.swift
//  Example
//
//  Created by Luciano Polit on 6/12/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import RepositoryKit

// MARK: - Main
struct Message: RKIdentifiable, RKPatchable {
    
    // Entity identification.
    var id: String
    // Dictionary memory.
    var dictionaryMemory: Dictionary<String, Any> = [:]
    // Properties.
    var text: String
    var date: Date?
    
}

// MARK: - Dictionary Initializable implementation
extension Message: RKDictionaryInitializable {
    
    // Initialize with a dictionary.
    init?(dictionary: Dictionary<String, Any>) {
        
        // Here we will have the dictionary that should initialize the entity.
        // We have to be careful that every information we need is inside the dictionary.
        // If not, return nil, and we will have an error in the promise of the repository operation.
        guard let id = dictionary["_id"] as? String,
            let text = dictionary["text"] as? String
            else { return nil }
        
        // In case that we have the data needed, set it.
        self.id = id
        self.text = text
        
        // Optional case.
        if let date = dictionary["date"] as? Int {
            self.date = Date(timeIntervalSince1970: TimeInterval(date))
        }
        
        // Set dictionary memory.
        self.dictionaryMemory = dictionary
        
    }
    
}

// MARK: - Dictionary Representable implementation
extension Message: RKDictionaryRepresentable {
    
    // Dictionary representation.
    var dictionary: Dictionary<String, Any> {
        return [
            "_id": id,
            "text": text
        ]
    }
    
}
