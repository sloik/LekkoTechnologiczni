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
            .assertSnapshot("1_initial_game_state")
            .assertPlayer(.x)
            .assertMovesLeft(9)
            
            .move(.leftTop)
            .assertSnapshot("2_X_made_a_move_left_top")
            .assertPlayer(.o)
            .assertMovesLeft(8)
            
            .move(.centerTop)
            .assertSnapshot("3_O_made_a_move_center_top")
            .assertPlayer(.x)
            .assertMovesLeft(7)
            
            .move(.centerCenter)
            .assertSnapshot("4_X_made_a_move_center_center")
            .assertMovesLeft(6)
            
            .move(.rightTop)
            .assertSnapshot("5_O_made_a_move_right_top")
            .assertMovesLeft(5)
            
            .move(.rightBottom)
            .assertSnapshot("6_X_made_a_move_right_bottom_and_won_the_game")
            .assertWonByPlayer(.x)
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
    
    @discardableResult
    func assertSnapshot(
        _ name: String,
        file: StaticString = #filePath,
        line: UInt = #line,
        testName: String = #function) -> GamePlay {
        
        let displayInfo: DisplayInfo!
        switch gameState {
        case .playerXMove(let info, _): displayInfo = info
        case .playerOMove(let info, _): displayInfo = info
        case .gameWon(let info, _)    : displayInfo = info
        case .gameTie(let info)       : displayInfo = info
        }
        
        SnapshotTesting.assertSnapshot(
            matching: displayInfo |> displayBoard,
            as: .lines,
            named: name,
            timeout: 5,
            file: (file),
            testName: testName,
            line: line
        )
        
        return self
    }
    
    @discardableResult
    func assertPlayer(
        _ player: Player,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line) -> GamePlay {
        
        switch gameState {
        case .playerXMove:
            XCTAssertEqual(player, Player.x, message(), file: file, line: line)
        case .playerOMove:
            XCTAssertEqual(player, Player.o, message(), file: file, line: line)
        default:
            XCTFail("Game is in a state where no player can make any move!", file: file, line: line)
        }
        
        return self
    }
    
    @discardableResult
    func assertWonByPlayer(
        _ expected: Player,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line) -> GamePlay {
        
        switch gameState {
        case .gameWon(_, let player):
            XCTAssertEqual(expected, player, message(), file: file, line: line)
        
        default:
            XCTFail("Game is not in a Won state!")
        }
        
        return self
    }
    
    @discardableResult
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
