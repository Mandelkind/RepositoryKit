//
//  RKError.swift
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

import Foundation

/// Represents the possible errors that can be produced by the repositories methods.
public enum RKError: Error {
    
    /// Occurs when a initialization failed.
    case initialization
    
    /// Occurs when a dictionary can not be identified.
    case unidentifiable
    
    /// Occurs when a casting failed.
    case casting
    
    /// Occurs when a JSON parsing failed.
    case parsing
    
    /// Occurs when an entity is bad formed.
    case badEntity
    
    /// Occurs when there is a problem in a HTTP request.
    case badRequest
    
    /// Occurs when there is a problem in a HTTP response.
    case badResponse
    
    /// Occurs when a request returns with a server error.
    case server(statusCode: Int)
    
    /// Another type of error.
    case other(Error)
    
}
