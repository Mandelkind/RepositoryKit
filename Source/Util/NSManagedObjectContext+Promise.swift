//
//  NSManagedObjectContext+Promise.swift
//
//  Copyright (c) 2016 Luciano Polit <lucianopolit@gmail.com>
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

extension NSManagedObjectContext {
    
    /**
     Synchronously performs a given block on the receiver's queue.
     
     - Parameter block: Receive a closure that returns a promise of a generic type.
     
     - Returns: A promise of a generic type.
     */
    public func performAndWait<T>(_ block: @escaping (Void) -> Promise<T>) -> Promise<T> {
        
        return Promise { success, failure in
            
            self.performAndWait {
                
                block()
                    .then(execute: success)
                    .catch(execute: failure)
                
            }
            
        }
        
    }
    
    /**
     Asynchronously performs a given block on the receiver's queue.
     
     - Parameter block: Receive a closure that returns a promise of a generic type.
     
     - Returns: A promise of a generic type.
     */
    public func perform<T>(_ block: @escaping (Void) -> Promise<T>) -> Promise<T> {
        
        return Promise { success, failure in
            
            self.perform {
                
                block()
                    .then(execute: success)
                    .catch(execute: failure)
                
            }
            
        }
        
    }
    
    /**
     Attempts to commit unsaved changes to registered objects to the receiver's parent store.
     
     - Parameter t: A generic type that will be returned after success.
     
     - Returns: The specified generic type.
     */
    public func save<T>(_ t: T) throws -> T {
        
        try save()
        
        return t
        
    }
    
    /**
     Attempts to delete a `ManagedObject` from its persistent store.
     
     - Parameter object: A `ManagedObject`.
     */
    internal func delete(_ object: Any) throws {
        
        guard let managedObject = object as? NSManagedObject else {
            throw RKError.badEntity
        }
        
        delete(managedObject)
        
    }
    
}
