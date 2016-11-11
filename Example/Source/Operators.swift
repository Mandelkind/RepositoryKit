//
//  Operators.swift
//  Example
//
//  Created by Luciano Polit on 18/7/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import Foundation

infix operator <~

public func <~ <T, O>(lhs: inout T, rhs: O?) {
    if let new = rhs as? T {
        lhs = new
    }
}
