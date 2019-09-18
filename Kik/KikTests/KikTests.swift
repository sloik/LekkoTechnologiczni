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
        super.setUp()
        sut = KikBaseViewController()
    }

    override func tearDown() {
        sut.model = Array(repeating: .none, count: 9)
    }

    func test_checkIfAllSymbolsAreTheSame() {
        
        let symobols:[Symbol]  = Array(repeating:.X , count: 3)
        XCTAssert(sut.checkIfAllSymbolsAreTheSame(symbolLine: symobols))
    }
    
    func test_checkIfAllSymbolsAreTheSame_ShoudReturnFalseIfContainsNone() {
        let symobols:[Symbol]  = [.X, .O, .none]
        XCTAssertFalse(sut.checkIfAllSymbolsAreTheSame(symbolLine: symobols))
    }
    
    func test_checkIfEndGameReturnWin() {
        sut.model = Array(repeating: .X, count: 9)
        XCTAssertEqual(sut.gameEnded(), GameStateResult.winner)
    }
    
    func test_checkIfEndGameReturnTie() {
        sut.model = [.O, .X, .X,
                     .X, .O, .O,
                     .O, .O, .X]
        XCTAssertEqual(sut.gameEnded(), GameStateResult.tie)
    }
    
    func test_checkIfEndGameReturnPlaying() {
        sut.model = Array(repeating: .none, count: 9)
        XCTAssertEqual(sut.gameEnded(), GameStateResult.playing)
    }
    
    func test_checkIfLinesAreConvertedToSymbols() {
        sut.model = [.O, .O, .O,
                     .X, .X, .X,
                     .none, .none, .none]
        
        XCTAssertEqual(sut.convertLinesToSymbols(line: [0, 1, 2]),
                       [.O, .O, .O])
        
        XCTAssertEqual(sut.convertLinesToSymbols(line: [3, 4, 5]),
                       [.X, .X, .X])
        
        XCTAssertEqual(sut.convertLinesToSymbols(line: [6, 7, 8]),
                       [.none, .none, .none])
        
        XCTAssertEqual(sut.convertLinesToSymbols(line: [1, 3, 6]),
                       [.O, .X, .none])
        
    }
}
