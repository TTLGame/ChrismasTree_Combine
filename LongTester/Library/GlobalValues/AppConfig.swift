//
//  AppConfig.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation
final class AppConfig {
    static var shared = AppConfig()
    var language : Language = .vietnamese
}

enum Language: String, Codable {
    case vietnamese = "vi"
    case english = "en"

    var title: String {
        switch self {
        case .vietnamese: return Language.localized("vietnamese")
        case .english: return Language.localized("english")
        }
    }

    static func cases() -> [String] {
        return [
            Language.localized("vietnamese"),
            Language.localized("english")
        ]
    }

    static func type(index: Int) -> Language {
        switch index {
        case 0: return .vietnamese
        default: return .english
        }
    }
    
}
