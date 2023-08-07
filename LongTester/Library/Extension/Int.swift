//
//  Int.swift
//  LongTester
//
//  Created by Long on 5/16/23.
//

import Foundation

extension Int {
    func formatnumberWithDot() -> String {
        let formater = NumberFormatter()
        formater.groupingSeparator = "."
        formater.numberStyle = .decimal
        return formater.string(from: NSNumber(value: self))!
    }
    
    func formatnumberWithComma() -> String {
        let formater = NumberFormatter()
        formater.groupingSeparator = ","
        formater.numberStyle = .decimal
        return formater.string(from: NSNumber(value: self))!
    }
    
    func roundNumber(numberOfZero : Int, type : FloatingPointRoundingRule) -> Int {
        var numAddUp : Float = 1
        for _ in 0..<numberOfZero {
            numAddUp *= 10
        }
        var data = Float(self)
        data = data / numAddUp
        
        data.round(type)
        data = data * numAddUp
        return Int(data)
    }
}
