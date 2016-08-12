//
//  Repositories.swift
//  Example
//
//  Created by Luciano Polit on 10/8/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import Foundation

struct Repositories {
    
    static let user = UserRepository(coreDataStack: coreDataStack, networkingSession: networkingSession)
    
}