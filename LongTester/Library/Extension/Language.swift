//
//  Language.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation

extension Language {
    public static func localized(_ key : String) ->String {
        let path = Bundle.main.path(forResource: AppConfig.shared.language.rawValue, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(key, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
