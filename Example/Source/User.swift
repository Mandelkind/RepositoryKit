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


class User: NSManagedObject, RKNetworkingStorageEntity, RKSynchronizable, RKPatchable {
    
    // MARK: - Properties
    override var description: String {
        return "\(id) - \(firstName!) - \(lastName!) - \(synchronized!)"
    }
    
    var shortID: String {
        if id.characters.count > 2 {
            return id.substringWithRange(id.endIndex.advancedBy(-3) ..< id.endIndex)
        } else {
            return id
        }
    }
    
    var dictionary: Dictionary<String, AnyObject> {
        return [
            "_id": id,
            "firstName": firstName!,
            "lastName": lastName!
        ]
    }
    
    var dictionaryMemory: Dictionary<String, AnyObject> = [:]
    
    // MARK: - Initialization
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        if let _ = id, let _ = firstName, let _ = lastName {
            self.dictionaryMemory = self.dictionary
        }
    }
    
    required convenience init?(dictionary: Dictionary<String, AnyObject>, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context),
            let firstName = dictionary["firstName"] as? String,
            let lastName = dictionary["lastName"] as? String
            else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.firstName = firstName
        self.lastName = lastName
        if let id = dictionary["_id"] as? String {
            self.id = id
            self.synchronized = true
        } else {
            self.id = "-1"
            self.synchronized = false
        }
        self.dictionaryMemory = self.dictionary
    }
    
    // MARK: - Methods
    func update(dictionary: Dictionary<String, AnyObject>) {
        synchronized = true
        id <~ dictionary["_id"]
        firstName <~ dictionary["firstName"]
        lastName <~ dictionary["lastName"]
        dictionaryMemory = self.dictionary
    }
    
}