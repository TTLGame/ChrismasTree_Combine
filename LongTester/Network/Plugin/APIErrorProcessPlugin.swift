//
//  APIErrorProcessPlugin.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation
import Moya
import RxCocoa
//import CocoaLu
struct APIErrorProcessPlugin: PluginType {
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        switch result {
        case let .success(moyaResponse):
            return .success(moyaResponse)
        case let .failure(error):
            print("APIErrorProcess on error: \(String(describing: error))")
            return .failure(processError(error))
        }
    }

    func processError(_ error: MoyaError) -> MoyaError {
        do {
            if let detail = try error.response?.map(APIErrorDetail.self,
                                                    atKeyPath: "error",
                                                    using: JSONDecoder(),
                                                    failsOnEmptyData: false) {
                print("Error content: \(String(describing: detail))")
                return MoyaError.underlying(APIError.serverError(detail), error.response)
            } else {
                return error
            }
        } catch let parseError {
            print("Parse error json failed: \(String(describing: parseError))")
            if let string = try? error.response?.mapString() {
                print("Error content: \(string)")
            }
        }
        return error
    }
}
