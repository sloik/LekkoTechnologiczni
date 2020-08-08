import XCTest

import SnapshotTesting
import FunctionalAPI
import KikDomain
import Prelude

@testable import KikImplementation

final class GamePlayTests: XCTestCase {

    override func setUp() {
        super.setUp()
        SnapshotTesting.record = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_gamePlay() {
        // Initial Game State
        let game = kikAPI.newGame
        
        // Make a move
        var nextMove: MoveCapability!
        var gameResult: MoveResult = game()
        
        switch gameResult {

        case .playerXMove(let displayInfo, let nextMoves):
            nextMove = nextMoves |> nextMoveCapability(.leftTop)

            XCTAssertEqual(
                nextMoves.count, 9,
                "Player X should have all 9 cells avaiable!"
            )
            
            assertSnapshot(
                matching: displayInfo |> displayBoard ,
                as: .lines,
                named: "0_initial_game_state"
            )
            
        case .playerOMove(_, _):
            XCTFail("Player X should move first!")
        
        case .gameWon:
            XCTFail("Game should not be won after 1st move!")
            
        case .gameTie:
            XCTFail("Game should not be Tied after 1st move!")
        }
        
        // Run the move
        gameResult = nextMove()
        
        switch gameResult {
        case .playerOMove(let displayInfo, let nextMoves):
            nextMove = nextMoves |> nextMoveCapability(.centerTop)
            
            XCTAssertEqual(
                nextMoves.count, 8,
                "Player O should have 8 cells avaiable!"
            )
            
            assertSnapshot(
                matching: displayInfo |> displayBoard ,
                as: .lines,
                named: "1_after_X_left_top_move"
            )
        
        default:
            XCTFail("Player O turn to move!")
        }
        
        // Run the move
        gameResult = nextMove()
        
        switch gameResult {
        case .playerXMove(let displayInfo, let nextMoves):
            nextMove = nextMoves |> nextMoveCapability(.centerCenter)
            
            XCTAssertEqual(
                nextMoves.count, 7
            )
            
            assertSnapshot(
                matching: displayInfo |> displayBoard ,
                as: .lines,
                named: "2_after_O_center_top_move"
            )
            
        default:
            XCTFail()
        }
        
        // Run the move
        gameResult = nextMove()
        
        switch gameResult {
        case .playerOMove(let displayInfo, let nextMoves):
            nextMove = nextMoves |> nextMoveCapability(.rightTop)
            
            XCTAssertEqual(
                nextMoves.count, 6
            )
            
            assertSnapshot(
                matching: displayInfo |> displayBoard ,
                as: .lines,
                named: "3_after_X_center_center_move"
            )
            
        default:
            XCTFail()
        }
        
        
        // Run the move
        gameResult = nextMove()
        
        switch gameResult {
        case .playerXMove(let displayInfo, let nextMoves):
            nextMove = nextMoves |> nextMoveCapability(.rightBottom)
            
            XCTAssertEqual(
                nextMoves.count, 5
            )
            
            assertSnapshot(
                matching: displayInfo |> displayBoard ,
                as: .lines,
                named: "4_after_O_right_top_move"
            )
            
        default:
            XCTFail()
        }
        
        // Run the move
        gameResult = nextMove()
        
        switch gameResult {
        case .gameWon(let displayInfo, let player):
        XCTAssertEqual(
            player,
            Player.x,
            "Player X should have won the game after this move!"
        )
        
        assertSnapshot(
            matching: displayInfo |> displayBoard,
            as: .lines,
            named: "5_after_X_right_bottom_move"
        )
        
        default:
            XCTFail()
        }
    }
    
    
    func test_gameUsingTypes() {
        GamePlay(gameState: kikAPI.newGame())
            .assertMovesLeft(9)
            .move(.leftTop)         // X
            .assertMovesLeft(88, "After move should have less moves!")
            .move(.centerTop)       // O
            .assertMovesLeft(7)
            .move(.centerCenter)    // X
            .assertMovesLeft(6)
            .move(.rightTop)        // O
            .assertMovesLeft(5)
            .move(.rightBottom)     // X wins
    }
}

struct GamePlay {
    let gameState: MoveResult
    
    @discardableResult
    func move(_ pos: CellPosition) -> GamePlay {
        switch gameState {
        case .playerXMove(_, let nextMoves):
            let move = nextMoves |> nextMoveCapability(pos)
            
            return GamePlay(gameState: move())
            
        case .playerOMove(_, let nextMoves):
            let move = nextMoves |> nextMoveCapability(pos)
            
            return GamePlay(gameState: move())
            
        case .gameWon, .gameTie:
            return self
        }
    }
    
    func assertMovesLeft(
        _ count: Int,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line) -> GamePlay {
        
        switch gameState {
        case .playerXMove(_, let nextMoves):
            XCTAssertEqual(nextMoves.count, count, message(), file: file, line: line)
            
        case .playerOMove(_, let nextMoves):
            XCTAssertEqual(nextMoves.count, count, message(), file: file, line: line)
            
        case .gameWon, .gameTie:
            break
        }
        
        return self
    }
}

//public func XCTAssertEqual<T>(_ expression1: @autoclosure () throws -> T, _ expression2: @autoclosure () throws -> T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line)


func nextMoveCapability(_ cellPosition: CellPosition) -> ([NextMoveInfo]) -> MoveCapability {
    { nextMoves in
        nextMoves
            .first(where: { (nmi: NextMoveInfo) -> Bool in
                nmi.posToPlay == cellPosition
            })!
            .capability
    }
}

let displayBoard: (DisplayInfo) -> String =
    ^\DisplayInfo.cells >>> GameState.init(cells:) >>> toAscii
