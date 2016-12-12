//
//  XCTestCase+Util.swift
//  Example
//
//  Created by Luciano Polit on 7/12/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import XCTest
import PromiseKit

// MARK: - Util
extension XCTestCase {
    
    // After a test failure, execute the fail method.
    func failure(error: Error) {
        XCTFail(error.localizedDescription)
    }
    
    // Force failure generic for promises.
    func forceFailure<T>(_ t: T) {
        XCTFail()
    }
    
    // Void failure, there is no problem if a promise fails.
    func voidFailure(error: Error) { }
    
}
