
import XCTest
@testable import Kik

class KikModelTests: XCTestCase {
    
    var sut: KikModel!
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    
    func test_ResetGame_ShouldResetModel() {
        //arrange
        let mockModel: [Symbol] =
            [.O, .X, .O,
             .X, .O, .X,
             .none,.none,.none]
        sut = KikMock.kikFactory(model: mockModel)
        
        //act
        sut.resetGame()
        
        //assert
        XCTAssertEqual(sut.model, Array(repeating: .none, count: 9))
    }
    
    
    func test_DidTapElement_ShouldReturnWinnerState() {
        //arrange
        let almostWinningModel: [Symbol] =
            [.O, .X, .O,
             .X, .O, .X,
             .none,.none,.none]
        sut = KikMock.kikFactory(model: almostWinningModel)
        
        
        let result = sut.didTapElement(8)
        //assert
        XCTAssertEqual(result,GameStateResult.winner )
        
        switch result {
        case .winner:
            XCTAssertEqual(palyer, .O)
        default:
            XCTFail("dsfsfs")
        }
    }
    
    func test_DidTapElement_ShouldReturnTierState() {
        //arrange
        let almostTieModel: [Symbol] =
            [.O, .X, .X,
             .X, .O, .O,
             .none, .O, .X,]
        
        sut = KikMock.kikFactory(model: almostTieModel)
        
        //assert
        XCTAssertEqual(sut.didTapElement(6),GameStateResult.tie )
    }
    
    func test_DidTapElement_ShouldReturnPlayingState() {
        //arrange
        let playingModel: [Symbol] =
            [.none, .none, .none,
             .none, .none, .none,
             .none, .O, .X,]
        
        sut = KikMock.kikFactory(model: playingModel)
        
        //assert
        XCTAssertEqual(sut.didTapElement(1),GameStateResult.playing)
    }
    
    func test_LineToSymobol_ShouldReturnAprioriateSymbol() {
        //arrange
        let playingModel: [Symbol] =
            [.none, .none, .none,
             .none, .O, .none,
             .none, .O, .X]
        
        sut = KikMock.kikFactory(model: playingModel)
        
        //act
        let topLine = sut.lineToSymbols(Line.topRow)
        let midLine = sut.lineToSymbols(Line.midRow)
        let bottomLine = sut.lineToSymbols(Line.bottomRow)
        
        //assert
        XCTAssertEqual(topLine, [.none, .none, .none])
        XCTAssertEqual(midLine, [ .none, .O, .none])
        XCTAssertEqual(bottomLine, [.none, .O, .X])
    }
    
    func test_GameEnded_ShouldReturnWinningGameState() {
        //arrange
        let winningModel: [Symbol] =
            [.O, .X, .O,
             .X, .O, .X,
             .none,.none,.O]
        
        sut = KikMock.kikFactory(model: winningModel)
        XCTAssertEqual(sut.gameEnded(), GameStateResult.winner)
    }
    
    func test_GameEnded_ShouldReturnTieGameState() {
        //arrange
        let tieModel: [Symbol] =
            [.O, .X, .X,
             .X, .O, .O,
             .X, .O, .X,]
        
        sut = KikMock.kikFactory(model: tieModel)
        XCTAssertEqual(sut.gameEnded(), GameStateResult.tie)
    }
    
    func test_GameEnded_ShouldReturnPlayingGameState() {
        //arrange
        let playingModel: [Symbol] =
            [.none, .none, .none,
             .none, .O, .none,
             .none, .O, .X]
        
        sut = KikMock.kikFactory(model: playingModel)
        
        //assert
        XCTAssertEqual(sut.gameEnded(), GameStateResult.playing)
    }
    
    func test_allSymbolsAreTheSame_ShouldReturnTrue() {
        //arrange
        let mockModel: [Symbol] =
            [.X, .X, .X,
             .none, .O, .none,
             .none, .O, .X]
        
        sut = KikMock.kikFactory(model: mockModel)
        
        //assert
        XCTAssertTrue(sut.allSymbolsAreTheSame(line: Line.topRow))
    }
    
    func test_allSymbolsAreTheSame_ShouldReturnFalse() {
        //arrange
        let mockModel: [Symbol] =
            [.X, .X, .X,
             .none, .O, .none,
             .none, .O, .X]
        
        sut = KikMock.kikFactory(model: mockModel)
        
        //assert
        XCTAssertFalse(sut.allSymbolsAreTheSame(line: Line.bottomRow))
    }
}

struct KikMock {
    static func kikFactory(model: [Symbol]) -> KikModel {
        return KikModel(currentSymbol: .O, model: model)
    }
}
