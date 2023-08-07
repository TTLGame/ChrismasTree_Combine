//
//  ProviderAPIWithAccessToken.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation
import RxSwift
import Moya

class ProviderAPIWithAccessToken<Target>: Provider<Target> where Target: Moya.TargetType {
    let provider: MoyaProvider<Target>
    let prefs: PrefsAccessToken
    let autoHandleAccessTokenExpired: Bool
    let autoHandleAPIError: Bool
    let autoHandleNoInternetConnection: Bool

    /**
     Init Provider, similiar to Moya.
     - Parameter prefs: Access token storage
     - Parameter autoHandleAccessTokenExpired: If `true` then errors which caused the app to
     auto logout will be handled automatically, and will be transformed into `APIError.ignore`
     - Parameter autoHandleAccountSuspendedStop: If `true` then errors which caused the app to
     auto logout will be handled automatically, and will be transformed into `APIError.ignore`
     - Parameter autoHandleAPIError: If `true` then any error thrown will be handled automatically,
     and will be transformed into `APIError.ignore`
     */
    init(prefs: PrefsAccessToken & PrefsRefreshToken = PrefsImpl.default,
         autoHandleAccessTokenExpired: Bool = true,
         autoHandleNoInternetConnection: Bool = true,
         autoHandleAPIError: Bool = true,
         endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
         session: Session = DefaultAlamofireManager.shared,
         plugins: [PluginType] = [],
         trackInflights: Bool = false) {
        self.prefs = prefs
        self.autoHandleAccessTokenExpired = autoHandleAccessTokenExpired
        self.autoHandleAPIError = autoHandleAPIError
        self.autoHandleNoInternetConnection = autoHandleNoInternetConnection

        // Set up plugins
        var mutablePlugins: [PluginType] = plugins
        let errorProcessPlugin: APIErrorProcessPlugin = APIErrorProcessPlugin()
        mutablePlugins.append(errorProcessPlugin)
        #if DEBUG
        mutablePlugins.append(
            NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))
        )
        #endif
        let accessTokenPlugin: AccessTokenPlugin = AccessTokenPlugin { (_) -> String in
            return prefs.getAccessToken() ?? ""
        }
        mutablePlugins.append(accessTokenPlugin)

        provider = MoyaProvider(endpointClosure: endpointClosure,
                                requestClosure: requestClosure,
                                stubClosure: stubClosure,
                                session: session,
                                plugins: mutablePlugins,
                                trackInflights: trackInflights)
    }

    override func request(_ token: Target) -> Single<Moya.Response> {
        let request = provider.rx.request(token)
        
        print("API CALLER ----------------------")
        let url = token.baseURL.absoluteString + token.path
        print("API >>> URL : \(url)")
        print("API >>> METHOD : \(token.method.rawValue)")
        switch token.task {
        case let .requestParameters(parameters,_):
            print("API >>> PARAMS : \(parameters)")
        default:
            break
        }
        return request
            .catch({ (error) in
                if case MoyaError.underlying(let underlyingError, let response) = error,
                   case APIError.serverError(let detail) = underlyingError {
                    let accessTokenExpired: Bool = (detail.statusCode == 401003)
                    if accessTokenExpired == true {
                        return Single.error(MoyaError.underlying(APIError.accessTokenExpired(error), response))
                    } else {
                        return Single.error(error)
                    }
                } else {
                    return Single.error(error)
                }
            })
                .catch({ (error) in
                // Handle access token expired
                if case MoyaError.underlying(APIError.accessTokenExpired(_), _) = error,
                   self.autoHandleAccessTokenExpired == true {
                    NotificationCenter.default.post(name: .AutoHandleAccessTokenExpired, object: nil)
                    return Single.error(APIError.ignore(error))
                } else {
                    return Single.error(error)
                }
            })
            .catchCommonError(autoHandleNoInternetConnection: autoHandleNoInternetConnection,
                              autoHandleAPIError: autoHandleAPIError)
    }
}
