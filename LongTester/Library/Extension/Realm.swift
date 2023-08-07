//
//  Realm.swift
//  LongTester
//
//  Created by Long on 4/10/23.
//

import Foundation
import RealmSwift
extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        return array
    }
}

extension Encodable {
  func asDictionary() throws -> JSObject {
    let data = try JSONEncoder().encode(self)
      guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}
