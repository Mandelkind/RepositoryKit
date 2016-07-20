//
//  User+CoreDataProperties.swift
//  Example
//
//  Created by Luciano Polit on 20/7/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var id: String!
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var synchronized: NSNumber?

}
