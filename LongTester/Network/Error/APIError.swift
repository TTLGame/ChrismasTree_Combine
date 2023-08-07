//
//  APIError.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation
import Moya

protocol LocalizedAppError {
    var appErrorDescription: String? { get }
}

/**
 Error when calling api
 */

enum ReadError: Error{
    case invalidURL
}

enum APIError: Error {
    case ignore(_ error: Error)
    case accessTokenExpired(_ error: Error)
    case serverError(_ detail: APIErrorDetail)
    case parseError
    case systemError
    case jtiError(_ message: String?)
}

struct APIErrorDetail: Error, Codable {
    let statusCode: Int
    let messageVN: String?
    let messageEN: String?

    var localizedDescription: String {
        let string = AppConfig.shared.language == .vietnamese ? messageVN : messageEN
        return string ?? ""
    }
}

extension APIError: LocalizedAppError {
    var appErrorDescription: String? {
        switch self {
        case .serverError(let detail):
            return detail.appErrorDescription
        case .jtiError(let message):
            return message
        case .systemError:
            return "System error"
        default:
            return nil
        }
    }
}

extension APIErrorDetail: LocalizedAppError {
    var appErrorDescription: String? {
        AppConfig.shared.language == .vietnamese ? messageVN : messageEN
    }
}

extension MoyaError: LocalizedAppError {
    var appErrorDescription: String? {
        switch self {
        case .underlying(let error, _):
            if let unwrapped = error as? LocalizedAppError {
                return unwrapped.appErrorDescription
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

struct SimpleError: Error {
    let message: String?
}

extension SimpleError: LocalizedAppError {
    var appErrorDescription: String? {
        return message
    }
}
