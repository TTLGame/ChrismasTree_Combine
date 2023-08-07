//
//  Environment.swift
//  LongTester
//
//  Created by Long on 4/10/23.
//

import Foundation

import Foundation

enum EnvironmentType: String {
    case normal
    case pico
}

enum PlistKey: String, CaseIterable {
    case environmentType
    case apiHost
    case apiPath
}

class Environment: NSObject {
    static let shared: Environment = Environment()

    fileprivate var infoDict: [String: Any] = Bundle.main.infoDictionary!

    func logEnvironmentInfos() {
        // Print environment values
        var string: String = ""
        for key: PlistKey in PlistKey.allCases {
            if let value: String = self.infoDict[key.rawValue] as? String {
                let lineString: String = key.rawValue + ": " + value
                string += "\n" + lineString
            }
        }
        string += "\n\n" + "Webview urls:"
        for webviewUrl: WebviewUrlDef in WebviewUrlDef.allCases {
            let urlString: String = webviewUrl.urlString()
            let url: URL? = URL(string: urlString)
            assert(url != nil, String(format: "Invalid url. Please check: %@", urlString))
            let lineString: String = webviewUrl.rawValue + ": " + url!.absoluteString
            string += "\n" + lineString
        }
        print("Environment init with following values: \(string)")

    }

    func configuration(_ key: PlistKey) -> String {
        let value: Any? = infoDict[key.rawValue]
        let result: String? = value as? String
        assert(result != nil, String(format:
                                        """
                                        Value for environment config key \"%@\" does not exist or is invalid. \
                                        Please check info.plist if the key exist and configuration file \
                                        is selected in project build configuration.
                                        """, key.rawValue))
        return result!
    }

    var environmentType: EnvironmentType {
        let string = self.configuration(.environmentType)
        let value = EnvironmentType(rawValue: string)
        assert(value != nil, String(format:
                                        """
                                        Value for environment config key \"%@\" does not exist or is invalid. \
                                        Please check info.plist if the key exist and configuration file \
                                        is selected in project build configuration.
                                        """, PlistKey.environmentType.rawValue))
        return value!
    }
}

enum WebviewUrlDef: String, CaseIterable {
    case terms = "termsofservice.html"
    case policies = "privacy.html"
    case resetPassword = "resetPassword"

    func urlString() -> String {
        let host: String = Environment.shared.configuration(.apiHost)
        let urlString: String = host + self.rawValue
        return urlString
    }
}
