//
//  Storage.swift
//
//  Copyright (c) 2016-2017 Luciano Polit <lucianopolit@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import CoreData
import PromiseKit

/// It is needed to be considered a *Storage Recipe* by a *Repository*.
public protocol Storage {
    
    /**
     Attempts to commit unsaved changes from the main context to the persistence context.
     
     - Parameter t: A generic type that will be returned with a promise.
     
     - Returns: A promise of the generic type.
     */
    func save<T>(_ t: T) -> Promise<T>
    
    /**
     Performs an operation in the main queue.
     
     - Parameter block: the closure to perform (receive the context and return a promise of a generic type).
     
     - Returns: A promise of a generic type.
     */
    func performOperation<T>(_ block: @escaping (NSManagedObjectContext) -> Promise<T>) -> Promise<T>
    
    /**
     Performs an operation in a background queue.
     
     - Parameter block: the closure to perform (receive the context and return a promise of a generic type).
     
     - Returns: A promise of a generic type.
     */
    func performBackgroundOperation<T>(_ block: @escaping (NSManagedObjectContext) -> Promise<T>) -> Promise<T>
    
}
