//
//  MonthYearTests.swift
//  LongTesterTests
//
//  Created by Long on 5/24/23.
//

import XCTest
@testable import LongTester
final class MonthYearTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMonthYearOperator() throws {
        let currentDate = MonthYear(month: 10, year: 2000)
        let lastDate = MonthYear(month: 9, year: 2000)
        XCTAssertEqual(currentDate - 1, lastDate,"Fail to test equal and minus MonthYear operator")
    }

    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
