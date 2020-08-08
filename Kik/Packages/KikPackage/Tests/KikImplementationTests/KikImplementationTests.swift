
import XCTest

import SnapshotTesting
import FunctionalAPI
import KikDomain

@testable import KikImplementation

final class KikImplementationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        SnapshotTesting.record = false
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func test_linesToCheck_should_defineAllLinesInGame() {
        assertSnapshot(
            matching: linesToCheck.map( toString ).joined(separator: "\n"),
            as: .lines
        )
    }

    func test_getCell_shouldReturn_cellByItsPosition() {
        // Arrange
        let gameState = GameState(cells: repeatedCells)
        
        precondition(
            repeatedCells.count == allPositions.count
        )
        
        // Act
        let result: [Cell] = allPositions
            .map( getCell(gameState) )
        
        // Assert
        XCTAssertTrue(
            result.count == gameState.cells.count,
            "Should have got cell for each position!"
        )
        
        XCTAssertEqual(
            result,
            repeatedCells
        )
    }
    
    func test_updateCell_should_returnNewGameState_with_theCellInsertedInPlace() {
        // Arrange
        let emptyGameState = GameState(cells: allEmptyCells)
        
        // Act
        allXCells
            .forEach{ (cell: Cell) in
                let result: GameState = updateCell(cell)(emptyGameState)
                
                let value =
                """
                UPDATE CELL:
                \(toString(cell))

                RESULT
                \(toString(result))
                """
                assertSnapshot(matching: value, as: .lines)
            }
    }
    
    func test_isGameWonByPlayer_shouldReturnTrue_forWinngingState() {
        // arrange
        let xWinningStates: [GameState] = linesToCheck
            .map(winningState(in: GameState(cells: allEmptyCells), for: .x))
        
        let didXWonTheGame = isGameWonBy(.x)
        let didOWonTheGame = isGameWonBy(.o)
        
        // Act
        
        XCTAssertEqual(
            xWinningStates.count,
            8
        )
        
        xWinningStates
            .forEach { (gameState) in
                XCTAssertTrue(
                    didXWonTheGame(gameState),
                    """
                    X should won the game:
                    \(toAscii(gameState))
                    """
                )
                
                XCTAssertFalse(
                    didOWonTheGame(gameState),
                    """
                    O should not won the game:
                    \(toAscii(gameState))
                    """
                )
            }
    }
    
    func test_ifGameIsTied_should_returnTrue_whenAllCellsArePalyed() {
        XCTAssertFalse(
            isGameTied(
                GameState(cells: allEmptyCells)
            )
        )
        
        XCTAssertTrue(
            isGameTied(
                GameState(cells: allXCells)
            )
        )
    }
    
    func test_remainingMoves_should_reurnAllNonPlayedCells() {
        XCTAssertEqual(
            remainingMoves( GameState(cells: allXCells) ).count,
            0
        )
        
        XCTAssertEqual(
            remainingMoves( GameState(cells: allEmptyCells) ).count,
            9
        )
    }
    
    func test_playerMove_should_returnMoveResultWhereCellIsPlayedByPlayer() {
        // Arrange
        let emptyGameState = GameState(cells: allEmptyCells)
        
        // Act
        let result = playerMove(player: .o, cellPos: .leftTop, gameState: emptyGameState)
        
        // Assert
        switch result {
        case .playerXMove(let displayInfo, let nextMoves):
            XCTAssertEqual(nextMoves.count, 8)
            
            assertSnapshot(
                matching: toAscii( GameState(cells: displayInfo.cells) ) ,
                as: .lines
            )
            
        case .playerOMove:
            XCTFail("On empty board after O player X should move next!")
            
        default:
            XCTFail("This is imposible after 1st move!")
        
        }
    }
}


