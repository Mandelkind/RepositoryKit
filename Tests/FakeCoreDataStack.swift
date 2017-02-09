//
//  FakeCoreDataStack.swift
//  Example
//
//  Created by Luciano Polit on 5/12/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import CoreData
import RepositoryKit

class FakeCoreDataStack: CoreDataStack {
    
    // MARK: - Initialization
    override init(modelName: String, bundle: Bundle = Bundle.main, addStore: Bool = false) throws {
        // Super init.
        try super.init(modelName: modelName, bundle: bundle, addStore: addStore)
        // Add persistent store.
        try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    }
    
}
