//
//  SharedInstances.swift
//  Example
//
//  Created by Luciano Polit on 18/7/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import RepositoryKit

var coreDataStack = RKCoreDataStack(modelName: "Model")!
var networkingSession = RKNetworkingSession(url: "http://localhost:3000")