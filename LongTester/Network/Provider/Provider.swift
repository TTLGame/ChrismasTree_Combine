//
//  Provider.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation
import RxSwift
import Alamofire
import Moya

class Provider<Target> where Target: Moya.TargetType {
    func request(_ token: Target) -> Single<Moya.Response> {
        fatalError("This class is used directly which is forbidden")
    }
}

extension Single where Element: Moya.Response {
    func handleCommonError(_ error: Error,
                           autoHandleNoInternetConnection: Bool,
                           autoHandleAPIError: Bool) -> Single<Element> {
        guard case MoyaError.underlying(let underlyingError, _) = error else {
            return Single<Element>.error(error)
        }
        // Handle no internet connection automatically if needed
        if case AFError.sessionTaskFailed(error: let sessionError) = underlyingError,
           let urlError = sessionError as? URLError,
           urlError.code == URLError.Code.notConnectedToInternet ||
            urlError.code == URLError.Code.timedOut ||
            urlError.code == URLError.Code.dataNotAllowed {
            if autoHandleNoInternetConnection == true {
                NotificationCenter.default.post(name: .AutoHandleNoInternetConnectionError, object: error)
                return Single<Element>.error(APIError.ignore(error))
            } else {
                return Single<Element>.error(error)
            }
        }
        // Handle api error automatically if needed
        else if autoHandleAPIError == true {
            NotificationCenter.default.post(name: .AutoHandleAPIError, object: error)
            return Single<Element>.error(APIError.ignore(error))
        } else {
            return Single<Element>.error(error)
        }
    }

    func catchCommonError(autoHandleNoInternetConnection: Bool,
                          autoHandleAPIError: Bool) -> Single<Element> {
        guard let unwrapped = self as? Single<Element> else { return Single.error(APIError.systemError) }

        return unwrapped.catchError { (error) -> Single<Element> in
            self.handleCommonError(error,
                                   autoHandleNoInternetConnection: autoHandleNoInternetConnection,
                                   autoHandleAPIError: autoHandleAPIError)
        }
    }
}

extension Notification.Name {
    static let AutoHandleAPIError: Notification.Name = Notification.Name("AutoHandleAPIError")
    static let AutoHandleNoInternetConnectionError: Notification.Name =
        Notification.Name("AutoHandleNoInternetConnectionError")
    static let AutoHandleAccessTokenExpired: Notification.Name = Notification.Name("AutoHandleAccessTokenExpired")
    static let AccountSuspendedStop: Notification.Name = Notification.Name("AccountSuspendedStop")
}
