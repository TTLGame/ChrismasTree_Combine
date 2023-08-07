//
//  MainScreenTarget.swift
//  LongTester
//
//  Created by Long on 4/10/23.
//

import Foundation
import Moya

public enum MainScreenTarget {
    case getUser(page: Int)
    case getAddress
    case deleteAddress(id: String)
    case createAddress(quota: Int,
                       quotaPrice: Int,
                       roomPrice: Int,
                       waterPrice: Int,
                       electricPrice: Int,
                       roomsNum : Int,
                       address: String,
                       name: String)
      
}

extension MainScreenTarget: TargetType {
    public var method: Moya.Method {
        switch self {
        case .getUser:
            return .get
        case .getAddress:
            return .get
        case .createAddress :
            return .post
        case .deleteAddress :
            return .delete
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .getUser(let page):
            return .requestParameters(parameters: ["page":page],
                                      encoding: URLEncoding.default)
        case .getAddress :
            return .requestPlain
        case .deleteAddress :
            return .requestPlain
        case let .createAddress(quota, quotaPrice, roomPrice, waterPrice, electricPrice, roomsNum, address, name) :
            return .requestParameters(parameters:["inputQuotaPrice": quotaPrice,
                                                  "inputElectric": electricPrice,
                                                  "inputRoomPrice": roomPrice,
                                                  "inputWater": waterPrice,
                                                  "inputRooms": roomsNum,
                                                  "inputAddress": address,
                                                  "inputQuota": quota,
                                                  "inputName": name],
                                      encoding: JSONEncoding.default)
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
        case .getUser:
            return "users"
        case .getAddress:
            return "address/get"
        case .deleteAddress(let id) :
            return "address/\(id)/delete"
        case .createAddress :
            return "address/create"
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

extension MainScreenTarget: AccessTokenAuthorizable {
    public var authorizationType: AuthorizationType? {
        return .bearer
    }
}
