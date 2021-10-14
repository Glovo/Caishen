//
//  CardNumberFormatterTests.swift
//  Caishen
//
//  Created by Daniel Vancura on 2/9/16.
//  Copyright © 2016 Prolific Interactive. All rights reserved.
//

import XCTest
import Caishen

class CardNumberFormatterTests: XCTestCase {
    
    private let separator = "-"
    private var formatter: CardNumberFormatter!
    
    override func setUp() {
        super.setUp()

        let cardTypeRegister = CardTypeRegister(registeredCardTypes:  CardTypeRegister.defaultCardTypes + [MultipleGroupingsCardType()])
        formatter = CardNumberFormatter(cardTypeRegister: cardTypeRegister, separator: separator)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCorrectSeparator() {
        let testNumber = Number(rawValue: "4123123412341234")
        
        let formattedTestNumber = self.formatter.format(cardNumber: testNumber.description)
        
        XCTAssertEqual(formattedTestNumber, "4123-1234-1234-1234")
    }

    func testCorrectSeparatorMultipleGroupings() {
        let expectedMappings = [
            "6799990100000000": "6799-9901-0000-0000",
            "67999901000000000": "6799-9901-0000-0000-0",
            "679999010000000001": "6799-9901-0000-0000-01",
            "6799990100000000019": "6799-9901-0000-0000-019"
        ]

        expectedMappings.forEach {
            XCTAssertEqual($0.value, self.formatter.format(cardNumber: $0.key))
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
