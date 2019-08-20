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
    
    private func generateLine() -> [Symbol] {
        var symbols: [Symbol] = []
        
        for _ in 0...2 {
                   symbols.append(Symbol.allCases.randomElement()!)
               }
        return symbols
    }
    
    func test_checkIfSymbolsAreTheSame() {
        let symbols = generateLine()
        XCTAssertFalse(sut.checkIfAllSymbolsAreTheSame(symbolLine: generateLine()), "Sybols was: \(symbols)")
    }
}
