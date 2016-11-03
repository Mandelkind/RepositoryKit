//
//  PromisePrinter.swift
//  Example
//
//  Created by Luciano Polit on 18/7/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import PromiseKit

/// Given a generic type, it will print it, and return a promise with it.
/// It is useful to print something between promises.
func printer<T>(t: T) -> Promise<T> {
    
    return Promise { success, failure in
        
        print(t)
        
        success(t)
        
    }
    
}