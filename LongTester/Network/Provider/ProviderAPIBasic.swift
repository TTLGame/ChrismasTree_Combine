//
//  ProviderAPIBasic.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation
import Moya
import RxSwift
import Alamofire

class ProviderAPIBasic<Target>: Provider<Target> where Target: Moya.TargetType {
    let provider: MoyaProvider<Target>
    let autoHandleAPIError: Bool
    let autoHandleNoInternetConnection: Bool
    /**
     Init Provider, similiar to Moya.
     - Parameter autoHandleAPIError: If `true` then any error thrown will be
     handled automatically, and will be transformed into `APIError.ignore`
     */
    init(autoHandleNoInternetConnection: Bool = true,
         autoHandleAPIError: Bool = true,
         endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
         session: Session = DefaultAlamofireManager.shared,
         plugins: [PluginType] = [],
         trackInflights: Bool = false) {
        self.autoHandleAPIError = autoHandleAPIError
        self.autoHandleNoInternetConnection = autoHandleNoInternetConnection

        // Set up plugins
        let errorProcessPlugin: APIErrorProcessPlugin = APIErrorProcessPlugin()
        var mutablePlugins: [PluginType] = plugins
        mutablePlugins.append(errorProcessPlugin)
        #if DEBUG
        mutablePlugins.append(
            NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))
        )
        #endif

        provider = MoyaProvider(endpointClosure: endpointClosure,
                                requestClosure: requestClosure,
                                stubClosure: stubClosure,
                                session: session,
                                plugins: mutablePlugins,
                                trackInflights: trackInflights)
    }

    override func request(_ token: Target) -> Single<Response> {
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
        
        return provider.rx.request(token)
            .catchCommonError(autoHandleNoInternetConnection: autoHandleNoInternetConnection,
                              autoHandleAPIError: autoHandleAPIError)
    }
}
