//
//  ProviderType.swift
//  LongTester
//
//  Created by Long on 1/3/23.
//

import Foundation

enum ResultNew<T: Any> {
    case success(T)
    case failure(Error)
}

extension ResultNew where T == JSObject {
    func dataJson<Object>(type: Object.Type) -> Object? {
        guard case .success(let responseJson) = self else {
            return nil
        }
        if let responseJson = responseJson["data"] as? Object {
            return responseJson
        }
        return responseJson as? Object
    }
    func successValue() -> Bool? {
        guard case .success(let responseJson) = self else {
            return nil
        }
        if let bool = responseJson["success"] as? Bool {
            return bool
        }
        return nil
    }
    func messageValue() -> String? {
        guard case .success(let responseJson) = self else {
            return nil
        }
        if let message = responseJson["message"] as? String {
            return message
        }
        return nil
    }
    func resultCode() -> String? {
        guard case .success(let responseJson) = self else {
            return nil
        }
        if let result = responseJson["resultCode"] as? String {
            return result
        }
        return nil
    }
    var meta: Meta? {
        guard case .success(let responseJson) = self else {
            return nil
        }
        return Meta(json: responseJson)
    }
}

struct Meta: Model, Codable {
    var totalRows: Int
    var success: Bool
}
