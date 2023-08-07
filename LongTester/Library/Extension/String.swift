//
//  String.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation


extension String {
    func convertStringToDictionary() -> [String:Any]? {
        var text = self
        text.replaceSubrange(...text.startIndex, with: "{")
        text.replaceSubrange(text.index(before: text.endIndex)...text.index(text.endIndex,offsetBy: -1), with: "}")
//        print(text)
            
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    public func index(of target: String) -> Int? {
        if let range = self.range(of: target) {
            return distance(from: startIndex, to: range.lowerBound)
        } else {
            return nil
        }
    }
    
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func matches(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
                let range = NSRange(location: 0, length: self.utf16.count)
                return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}


