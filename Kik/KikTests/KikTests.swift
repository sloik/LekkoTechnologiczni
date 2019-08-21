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
        sut.model = Array(repeating: .none, count: 9)
    }
    
    func test_checkIfSymbolsAreTheSame() {
        let symbols = Array(repeating: Symbol.X, count: 3)
        XCTAssert(sut.checkIfAllSymbolsAreTheSame(symbolLine: symbols), "Error: symbols are not the same, symbols was \(symbols)")
    }
    
    func test_checkIfGameEndedReturnWin() {
        sut.model = Array(repeating: .X, count: 9)
        XCTAssertEqual(sut.gameEnded(), GameStateResult.winner)
    }
    
    func test_checkIfGameEndedReturnPlaying() {
        sut.model = Array(repeating: .none, count: 9)
        XCTAssertEqual(sut.gameEnded(), GameStateResult.playing)
    }
    
    func test_checkIfGameEndedReturnTie() {
        sut.model = [.O, .X, .X, .X, .O, .O, .O, .O, .X,]
        XCTAssertEqual(sut.gameEnded(), GameStateResult.tie)
    }
    func test_checIfLinesAreConvertedToSymbols() {
        sut.model = [.O]
        let converted = sut.convertLinesToSymbols(line: [0])
        XCTAssert(converted.contains(.O), "Error: sybmbol is not .O, symbol was converted to \(converted)")
        XCTAssertEqual(converted, sut.model)
    }
}
