//
//  SharedInstances.swift
//  Example
//
//  Created by Luciano Polit on 18/7/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import RepositoryKit

/// Shared instance of a Core Data stack.
var coreDataStack = try! CoreDataStack(modelName: "Model")
/// Shared instance of a Networking session.
var networkingSession = NetworkingSession(url: "http://localhost:3000")
