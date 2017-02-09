//
//  Repository.swift
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

import Foundation

/// It is needed to be considered a *Repository*.
public protocol Repository {
    
    /// The associated entity type.
    associatedtype Entity
    
}

/// It is needed to be considered a *Networking Repository*.
public protocol NetworkingRepository: Repository {
    
    /// The store that will be able to make the HTTP requests.
    var store: Networking { get }
    
    /// The url of the server.
    var path: String { get }
    
}

/// It is needed to be considered a *Storage Repository*.
public protocol StorageRepository: Repository {
    
    /// The object that will manage the local storage.
    var store: Storage { get }
    
    /// The name of the entity of the model.
    var name: String { get }
    
}

/// It is needed to be considered a *Networking Storage Repository*.
public protocol NetworkingStorageRepository: Repository {
    
    /// The associated networking repository type.
    associatedtype NetworkingRepository: RepositoryKit.NetworkingRepository
    /// The associated storage repository type.
    associatedtype StorageRepository: RepositoryKit.StorageRepository
    
    /// The networking repository.
    var networking: NetworkingRepository { get }
    /// The storage repository.
    var storage: StorageRepository { get }
    
}

/// Enables the repository to know how to identify a `Dictionary`.
public protocol DictionaryIdentifier {
    
    /// The key that identifies the `Dictionary`.
    var identificationKey: String { get }
    
}
