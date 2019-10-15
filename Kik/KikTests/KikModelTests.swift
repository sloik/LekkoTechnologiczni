//
//import XCTest
//@testable import Kik
//
//class KikTests: XCTestCase {
//    
//    var sut: KikBaseViewController!
//    
//    override func setUp() {
//        super.setUp()
//        sut = KikBaseViewController()
//    }
//
//    override func tearDown() {
//        sut.model = Array(repeating: .none, count: 9)
//        super.tearDown()
//    }
//    
//    func test_checkIfSymbolsAreTheSame() {
//        let symbols = Array(repeating: Symbol.X, count: 3)
//        XCTAssert(sut.checkIfAllSymbolsAreTheSame(symbolLine: symbols), "Error: symbols are not the same, symbols was \(symbols)")
//    }
//    
//    func test_checkIfSymbolsAreTheSame_shouldReturnFalseIfLineContainsNone() {
//        let symbols: [Symbol] = [.none, .X, .X]
//        XCTAssertFalse(sut.checkIfAllSymbolsAreTheSame(symbolLine: symbols))
//    }
//    
//    func test_checkIfGameEndedReturnWin() {
//        sut.model = Array(repeating: .X, count: 9)
//        XCTAssertEqual(sut.gameEnded(), GameStateResult.winner)
//    }
//    
//    func test_checkIfGameEndedReturnPlaying() {
//        sut.model = Array(repeating: .none, count: 9)
//        XCTAssertEqual(sut.gameEnded(), GameStateResult.playing)
//    }
//    
//    func test_checkIfGameEndedReturnTie() {
//        sut.model = [.O, .X, .X,
//                     .X, .O, .O,
//                     .O, .O, .X,]
//        XCTAssertEqual(sut.gameEnded(), GameStateResult.tie)
//    }
//    func test_checkIfLinesAreConvertedToSymbols() {
//        sut.model = [   .X,    .X,   .X,
//                        .O,    .O,   .O,
//                     .none, .none, .none]
//
//
//        XCTAssertEqual(
//            sut.convertLinesToSymbols(line: [0, 1, 2]),
//                       [.X, .X, .X]
//        )
//
//        XCTAssertEqual(
//            sut.convertLinesToSymbols(line: [3, 4, 5]),
//                       [.O, .O, .O]
//        )
//
//        XCTAssertEqual(
//            sut.convertLinesToSymbols(line: [6, 7, 8]),
//                       [.none, .none, .none]
//        )
//
//        XCTAssertEqual(
//            sut.convertLinesToSymbols(line: [1, 3, 6]),
//                       [.X, .O, .none]
//        )
//    }
//}
