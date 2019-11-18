import XCTest
@testable import Kik

class KikModelTests: XCTestCase {

    var sut: KikModel!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_ResetGame_ShouldResetModel() {
        //arrange
        let mockGameState: [Symbol] = [.O,.O,.X,.none,.O]
        sut = kikMock(model: mockGameState)

        //act
        sut.resetGame()

        //assert
        XCTAssertEqual(sut.gameState, Array(repeating: .none, count: 9))
    }

    func test_DidTapElement_ShouldReturnWinnerState() {
        //arrange
        let almostWinnigModel: [Symbol] = [.O, .X, .O,
                                           .X, .O, .X,
                                           .none, .none, .none]
        sut = kikMock(model: almostWinnigModel)

        //act
        let result = sut.didTapElement(8)

        //assert
        XCTAssertEqual(result, .winner(.O))
    }

    func test_DidTapElement_ShouldReturnTieState() {
        //arrange
        let almostTieModel: [Symbol] = [.O, .X, .X,
                                        .X, .O, .O,
                                        .none, .O, .X]
        sut = kikMock(model: almostTieModel)

        //act
        let result = sut.didTapElement(6)

        //assert
        XCTAssertEqual(result, .tie)
    }

    func test_DidTapElement_ShouldReturnPlayingState() {
        //arrange
        let playing: [Symbol] = Array(repeating: .none, count: 9)
        sut = kikMock(model: playing)

        //act
        let result = sut.didTapElement(2)
        
        //assert
        XCTAssertEqual(result, .playing)
    }

    func test_allSymbolsAreTheSame_ShouldReturnTrue() {
        //arrange
        let mockModel: [Symbol] = [.X, .X, .X]
        sut = kikMock(model: mockModel)
        //act
        let result = sut.allSymbolsAreTheSame(line: Line.topRow)
        //assert
        XCTAssertTrue(result)
    }

    func test_allSymbolsAreTheSame_ShouldReturnFalse() {
        //arrange
        let mockModel: [Symbol] = [.X, .X, .none]
        sut = kikMock(model: mockModel)
        //act
        let result = sut.allSymbolsAreTheSame(line: Line.topRow)
        //assert
        XCTAssertFalse(result)
    }
}

func kikMock(model: [Symbol]) -> KikModel {
    return KikModel(currentSymbol: .O, gameState: model)
}


