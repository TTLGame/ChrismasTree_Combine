//
//  IntTest.swift
//  LongTesterTests
//
//  Created by Long on 5/24/23.
//

import XCTest
@testable import LongTester
final class IntTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFormatnumberWithDot() throws {
        let number = 2000
        let converted = number.formatnumberWithDot()
        XCTAssertEqual(converted, "2.000", "Fail format integer to string with dot")
    }
    
    func testFormatnumberWithComma() throws {
        let number = 2000
        let converted = number.formatnumberWithComma()
        XCTAssertEqual(converted, "2,000", "Fail format integer to string with comma")
    }
    
    func testRoundNumber() throws {
        let number = 12345
        let convertedUp = number.roundNumber(numberOfZero: 3, type: .up)
        let convertedDown = number.roundNumber(numberOfZero: 3, type: .down)
        
        XCTAssertEqual(convertedUp, 13000, "Fail to round number up")
        XCTAssertEqual(convertedDown, 12000, "Fail to round number up")
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
