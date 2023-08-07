//
//  DefaultAlamofireManager.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation
import Alamofire

class DefaultAlamofireManager: Session {
    static let shared: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 20 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return DefaultAlamofireManager(configuration: configuration)
    }()
}
