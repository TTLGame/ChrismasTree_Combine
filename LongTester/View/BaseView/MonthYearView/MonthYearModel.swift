//
//  MonthYearModel.swift
//  LongTester
//
//  Created by Long on 5/23/23.
//

import Foundation

class MonthYear : Equatable{
    var month: Int
    var year: Int
    
    init() {
        let calendar = Calendar.current
        let date = Date()
        month = calendar.component(.month, from: date)
        year = calendar.component(.year, from: date)
    }
    
    init(month: Int, year: Int) {
        self.month = month
        self.year = year
    }
    
    static func +(lhs: MonthYear, rhs: Int) -> MonthYear {
        let totalYear = lhs.month + lhs.year * 12 + rhs
        let year = totalYear / 12
        let month = totalYear % 12
        
        return MonthYear(month: month, year: year)
    }
    
    static func -(lhs: MonthYear, rhs: Int) -> MonthYear {
        let totalYear = lhs.month + lhs.year * 12 - rhs
        let year = totalYear / 12
        let month = totalYear % 12
        
        return MonthYear(month: month, year: year)
    }
    
    static func ==(lhs: MonthYear, rhs: MonthYear) -> Bool {
        return (lhs.year == rhs.year) && (rhs.month == lhs.month)
    }
    
    static func !=(lhs: MonthYear, rhs: MonthYear) -> Bool {
        return (lhs.year != rhs.year) && (rhs.month != lhs.month)
    }
}
