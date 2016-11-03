//
//  User.swift
//  Example
//
//  Created by Luciano Polit on 20/7/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import RepositoryKit
import Foundation
import CoreData

/*
 It needs to conform:
    - RKNetworkingStorageEntity: it allows to be used as a `Networking entity` and a `Storage entity`.
    - RKSynchronizable: it allows to keep synchronized the both type of Repositories.
    - RKPatchable: it allows to be used to make PATCH requests.
 */
class User: NSManagedObject, RKNetworkingStorageEntity, RKSynchronizable, RKPatchable {
    
    // MARK: - Properties
    // It is changed to print some cleaner code.
    override var description: String {
        return "\(id) - \(firstName!) - \(lastName!) - \(synchronized!)"
    }
    
    // Avoid showing the entire id.
    var shortID: String {
        if id.characters.count > 2 {
            return id.substringWithRange(id.endIndex.advancedBy(-3) ..< id.endIndex)
        } else {
            return id
        }
    }
    
    // It represents the entity with a dictionary.
    var dictionary: Dictionary<String, AnyObject> {
        return [
            "_id": id,
            "firstName": firstName!,
            "lastName": lastName!
        ]
    }
    
    // It save a copy of the last representation on the `Networking repository store`.
    var dictionaryMemory: Dictionary<String, AnyObject> = [:]
    
    // MARK: - Initialization
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        // When an MO is inserted by a FRC, it is initialized by this way.
        // So we need to save a dictionary representation.
        // It will allow us to make patch requests from the beginning.
        if let _ = id, let _ = firstName, let _ = lastName {
            self.dictionaryMemory = self.dictionary
        }
    }
    
    // Initializes an object with a dictionary.
    required convenience init?(dictionary: Dictionary<String, AnyObject>, context: NSManagedObjectContext) {
        // Check for our requirements.
        guard let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context),
            let firstName = dictionary["firstName"] as? String,
            let lastName = dictionary["lastName"] as? String
            else { return nil }
        // Call the initializer.
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        // Update the properties.
        self.firstName = firstName
        self.lastName = lastName
        // If it is initialized with an 'id', use it,
        if let id = dictionary["_id"] as? String {
            self.id = id
        } else {
            self.id = "-1"
        }
        // If it is initialized from a `Networking entity`, it is synchronized.
        self.synchronized = self.id != "-1"
    }
    
    // MARK: - Methods
    // Updates self with a dictionary.
    func update(dictionary: Dictionary<String, AnyObject>) {
        synchronized = true
        id <~ dictionary["_id"]
        firstName <~ dictionary["firstName"]
        lastName <~ dictionary["lastName"]
        dictionaryMemory = self.dictionary
    }
    
}