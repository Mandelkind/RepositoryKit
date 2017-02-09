//
//  FakeNetworkingSession.swift
//  Example
//
//  Created by Luciano Polit on 5/12/16.
//  Copyright © 2016 Luciano Polit. All rights reserved.
//

import RepositoryKit
import PromiseKit

class FakeNetworkingSession: NetworkingSession {
    
    // MARK: - Parameters
    var lastPath: String!
    var lastMethod: HTTPMethod!
    var lastParameters: [String: Any]?
    var callback: ((Void) -> Void)?
    var answer: Any!
    
    // MARK: - Initialization
    init () {
        super.init(url: "")
    }
    
    // MARK: - Request
    override func request(method: HTTPMethod, path: String, parameters: [String : Any]? = nil, headers: [String : String]? = nil) -> Promise<Any> {
        // Save last info.
        lastPath = path
        lastMethod = method
        lastParameters = parameters
        // Return a fake promise.
        return Promise { success, failure in
            callback?()
            answer != nil ? success(answer) : failure(RKError.badResponse)
        }
    }
    
}
