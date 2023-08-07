//
//  LoginTarget.swift
//  LongTester
//
//  Created by Long on 6/3/23.
//

import Foundation
import Moya

public enum LoginTarget {
    case login(email: String, password: String)
    case register(request: RegisterReqModel)
}

extension LoginTarget: TargetType {
    public var method: Moya.Method {
        switch self {
        case .login:
            return .post
        case .register:
            return .post
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case let .login(email,password):
            return .requestParameters(parameters: ["email":email,
                                                   "password" : password],
                                      encoding: JSONEncoding.default)
        case let .register(request):
            let requestDict = request.json() ?? [:]
            return .requestParameters(parameters: requestDict, encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    public var baseURL: URL {
        let host: String = Environment.shared.configuration(.apiHost)
        let path: String = Environment.shared.configuration(.apiPath)
        let baseURL: URL = URL(string: host + path)!
        return baseURL
    }

    public var path: String {
        switch self {
        case .login:
            return "auth/login"
        case .register:
            return "auth/register"
        }
    }

    private func dataFromResource(name: String) -> Data {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil),
              let data = try? Data(contentsOf: url) else {
            return Data()
        }
        return data
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
    
    
}

extension LoginTarget: AccessTokenAuthorizable {
    public var authorizationType: AuthorizationType? {
        return .bearer
    }
}
