//
//  RKEntity.swift
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

/// Identify an entity with an *id* property.
public protocol Identifiable {
    
    /// The identifier type.
    associatedtype IdentifierType: CustomStringConvertible
    
    /// The identifier.
    var id: IdentifierType { get }
    
}

/// Represent if an object is up to date or not.
public protocol Synchronizable {
    
    /// The property that is the reference if the object is synchronized or not.
    var synchronized: NSNumber? { get }
    
}

/// Initialize an object with a `Dictionary`.
public protocol DictionaryInitializable {
    
    /// Initializes and returns a newly allocated object with the specified dictionary.
    init?(dictionary: Dictionary<String, AnyObject>)
    
}

/// Represent an object with a `Dictionary`.
public protocol DictionaryRepresentable {
    
    /// The property that represents the object with a `Dictionary`.
    var dictionary: Dictionary<String, AnyObject> { get }
    
}

/// Update an object with a `Dictionary`.
public protocol DictionaryUpdateable {
    
    /// The method that updates the object with a `Dictionary`.
    func update(dictionary: Dictionary<String, AnyObject>)
    
}

/// Initialize an object with a `Dictionary` and a `ManagedObjectContext`.
public protocol DictionaryContextInitializable {
    
    /// Initializes and returns a newly allocated object with the specified model name and managed object context.
    init?(dictionary: Dictionary<String, AnyObject>, context: NSManagedObjectContext)
    
}