//
//  KikTests.swift
//  KikTests
//
//  Created by Edward Maliniak on 30/07/2019.
//  Copyright © 2019 A.C.M.E. All rights reserved.
//

import XCTest
@testable import Kik

class KikTests: XCTestCase {
    
    var sut: KikBaseViewController!
    
    override func setUp() {
        sut = KikBaseViewController()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_checkIfSymbolsAreTheSame() {
        //arrange
        var symbols: [Symbol] = []
        
        for _ in 0...2 {
            symbols.append(Symbol.allCases.randomElement()!)
        }
        //assert
        XCTAssertFalse(sut.checkIfAllSymbolsAreTheSame(symbolLine: symbols), "Symbols are the same")
    }
}
