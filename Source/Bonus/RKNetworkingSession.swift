//
//  RKNetworkingSession.swift
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
import PromiseKit

// MARK: - Main
/// A networking session that makes requests to a server (which url is specified).
open class RKNetworkingSession: RKNetworking {
    
    // MARK: - Properties
    /// The url of the server.
    open var url: String
    
    /// A `Dictionary` with the HTTP request headers.
    open var requestHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
    
    // MARK: - Initialization
    /// Initializes and returns a newly allocated object with the specified url.
    public init(url: String) {
        self.url = url
        self.initConfiguration()
    }
    
    // MARK: - Private methods
    private func initConfiguration() {
        URLSession.shared.configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
    }
    
}

// MARK: - Request
extension RKNetworkingSession {
    
    /**
     Creates a promise with the response of a request for the specified method, url, parameters and headers.
     
     - Parameter method: The HTTP method.
     - Parameter path: The path of the URL.
     - Parameter parameters: The parameters (nil by default).
     - Parameter headers: The HTTP headers (nil by default).
     
     - Returns: A promise of `Any`.
     */
    open func request(method: RKMethod, path: String, parameters: Dictionary<String, Any>? = nil, headers: Dictionary<String, String>? = nil) -> Promise<Any> {
        
        return requestWithData(method, "\(url)/\(path)", parameters: parameters, headers: headers)
            .then { request in
                Promise { success, failure in
                    URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                        guard error == nil else {
                            failure(RKError.other(error!))
                            return
                        }
                        
                        guard let data = data, let response = response as? HTTPURLResponse else {
                            failure(RKError.badResponse)
                            return
                        }
                        
                        switch response.statusCode {
                        case 200...299: break
                        default: failure(RKError.server(statusCode: response.statusCode))
                        }
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                            success(json)
                        }
                        catch {
                            failure(RKError.parsing)
                        }
                        
                        }.resume()
                }
        }
        
    }
    
}

// MARK: - Utils
extension RKNetworkingSession {
    
    fileprivate func requestWithData(_ method: RKMethod, _ urlString: String, parameters: Dictionary<String, Any>?, headers: Dictionary<String, String>?) -> Promise<URLRequest> {
        
        return Promise { success, failure in
            
            guard let url = URL(string: urlString) else {
                failure(RKError.badRequest)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            
            if headers != nil {
                for (key, value) in headers! {
                    requestHeaders[key] = value
                }
            }
            
            for (key, value) in requestHeaders {
                request.addValue(value, forHTTPHeaderField: key)
            }
            
            guard let params = parameters else {
                success(request)
                return
            }
            
            do {
                let body = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
                request.httpBody = body
            }
            catch {
                failure(RKError.parsing)
            }
            
            success(request as URLRequest)
            
        }
        
    }
    
}
