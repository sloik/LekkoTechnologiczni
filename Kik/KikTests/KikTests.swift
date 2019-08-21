
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
        XCTAssert(sut.gameEnded() == GameStateResult.winner, "Error: game state is not valid")
    }
    
    func test_checkIfGameEndedReturnPlaying() {
        sut.model = Array(repeating: .none, count: 9)
        XCTAssert(sut.gameEnded() == GameStateResult.playing, "Error: game state is not valid")
    }
    
    func test_checkIfGameEndedReturnTie() {
        sut.model = [.O, .X, .X, .X, .O, .O, .O, .O, .X,]
        XCTAssert(sut.gameEnded() == GameStateResult.tie, "Error: game state is not valid")
    }
    func test_checIfLinesAreConvertedToSymbols() {
        sut.model = [.O]
        let converted = sut.convertLinesToSymbols(line: [0])
        XCTAssert(converted.contains(.O), "Error: sybmbol is not .O, symbol was converted to \(converted)")
        XCTAssert(converted == sut.model, "Error: symbol is not not converted, symbols are: \(converted)" )
    }
    
    
}
