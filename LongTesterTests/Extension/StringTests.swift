//
//  StringTests.swift
//  LongTesterTests
//
//  Created by Long on 5/24/23.
//

import XCTest
@testable import LongTester
final class StringTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testConvertStringToDictionary() throws {
        let dictString = "[\"id\" : \"1234\"]"
        let expectedDict : [String :Any] = ["id" : "1234"]
        let convertedDictString = dictString.convertStringToDictionary()
        XCTAssertNotNil(convertedDictString,"Fail to convert")
        XCTAssertEqual(convertedDictString!["id"] as? String, expectedDict["id"] as? String)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
