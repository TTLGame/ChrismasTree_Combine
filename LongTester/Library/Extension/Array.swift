//
//  Array.swift
//  LongTester
//
//  Created by Long on 1/3/23.
//

import Foundation

extension Array where Element == JSObject {
    func data() -> Data? {
        let strings = compactMap { (js) -> String? in
            return js.jsonString()
        }
        let joinedStr = strings.joined(separator: ",")
        let data = "[\(joinedStr)]".data(using: .utf8)
        return data
    }
}
