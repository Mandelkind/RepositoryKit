//
//  RKNetworking.swift
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

import PromiseKit

/// It is needed to be considered a *Networking recipe* by a *Repository*.
public protocol RKNetworking {
    
    /// The url of the server.
    var url: String { get }
    
    /**
     Creates a promise with the response of a request for the specified method, url, parameters and headers.
     
     - Parameter method: The HTTP method.
     - Parameter path: The path of the URL.
     - Parameter parameters: The parameters.
     - Parameter headers: The HTTP headers.
     
     - Returns: A promise of `AnyObject`.
     */
    func request(method: RKMethod, path: String, parameters: Dictionary<String, AnyObject>?, headers: Dictionary<String, String>?) -> Promise<AnyObject>
    
}

extension RKNetworking {
    
    public typealias DictionaryEntity = Dictionary<String, AnyObject>
    
    /**
     Creates a promise with the response of a request for the specified method, url, parameters and headers.
     
     - Parameter method: The HTTP method.
     - Parameter path: The path of the URL.
     - Parameter parameters: The parameters (nil by default).
     - Parameter headers: The HTTP headers (nil by default).
     
     - Returns: A promise of `DictionaryEntity`.
     */
    public func request(method: RKMethod, path: String, parameters: Dictionary<String, AnyObject>? = nil, headers: Dictionary<String, String>? = nil) -> Promise<DictionaryEntity> {
        
        return request(method, path: path, parameters: parameters, headers: headers)
            .then { result in
                Promise { success, failure in
                    guard let value = result as? DictionaryEntity else {
                        failure(RKError.casting)
                        return
                    }
                    success(value)
                }
            }
        
    }
    
    
    /**
     Creates a promise with the response of a request for the specified method, url, parameters and headers.
     
     - Parameter method: The HTTP method.
     - Parameter path: The path of the URL.
     - Parameter parameters: The parameters (nil by default).
     - Parameter headers: The HTTP headers (nil by default).
     
     - Returns: A promise of an `Array` of `DictionaryEntity`.
     */
    public func request(method: RKMethod, path: String, parameters: Dictionary<String, AnyObject>? = nil, headers: Dictionary<String, String>? = nil) -> Promise<[DictionaryEntity]> {
        
        return request(method, path: path, parameters: parameters, headers: headers)
            .then { result in
                Promise { success, failure in
                    guard let value = result as? [DictionaryEntity] else {
                        failure(RKError.casting)
                        return
                    }
                    success(value)
                }
            }
        
    }
    
    /**
     Creates a promise with the response of a request for the specified method, url, parameters and headers.
     
     - Parameter method: The HTTP method.
     - Parameter path: The path of the URL.
     - Parameter parameters: The parameters (nil by default).
     - Parameter headers: The HTTP headers (nil by default).
     
     - Returns: A promise of `Void`.
     */
    public func request(method: RKMethod, path: String, parameters: Dictionary<String, AnyObject>? = nil, headers: Dictionary<String, String>? = nil) -> Promise<Void> {
        
        return request(method, path: path, parameters: parameters, headers: headers)
            .then { _ in
                Promise { success, failure in
                    success()
                }
            }
        
    }
    
}