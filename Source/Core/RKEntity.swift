//
//  RKEntity.swift
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

/// It is required to be considered a *Dictionary Entity*.
public typealias RKDictionaryEntity = Dictionary<String, Any>

/// It is required to be considered a *Networking Entity*.
public typealias RKNetworkingEntity = RKIdentifiable & RKDictionaryRepresentable & RKDictionaryInitializable

/// It is required to be considered a *Networking Storage Entity*.
public typealias RKNetworkingStorageEntity = RKDictionaryContextInitializable & RKDictionaryRepresentable & RKDictionaryUpdateable & RKIdentifiable

/// It is required to be considered a *Storage Entity*.
public typealias RKStorageEntity = RKDictionaryContextInitializable

/// Identifies an entity with an *id* property.
public protocol RKIdentifiable {
    
    /// The identifier type.
    associatedtype IdentifierType: CustomStringConvertible
    
    /// The identifier.
    var id: IdentifierType { get }
    
}

/// Initializes an object with a `Dictionary`.
public protocol RKDictionaryInitializable {
    
    /// Initializes and returns a newly allocated object with the specified dictionary.
    init?(dictionary: Dictionary<String, Any>)
    
}

/// Represents an object with a `Dictionary`.
public protocol RKDictionaryRepresentable {
    
    /// The property that represents the object with a `Dictionary`.
    var dictionary: Dictionary<String, Any> { get }
    
}

/// Updates an object with a `Dictionary`.
public protocol RKDictionaryUpdateable: class {
    
    /// The method that updates the object with a `Dictionary`.
    func update(_ dictionary: Dictionary<String, Any>)
    
}

/// Initializes an object with a `Dictionary` and a `ManagedObjectContext`.
public protocol RKDictionaryContextInitializable: class {
    
    /// Initializes and returns a newly allocated object with the specified model name and managed object context.
    init?(dictionary: Dictionary<String, Any>, context: NSManagedObjectContext)
    
}

/// Represents if an object is synchronized or not.
public protocol RKSynchronizable {
    
    /// The property that represents if the object is synchronized or not.
    var synchronized: NSNumber? { get }
    
}

/// Keeps a dictionary memory.
public protocol RKPatchable {
    
    /// Represents a memory of the last updated entity.
    var dictionaryMemory: Dictionary<String, Any> { get set }
    
}
