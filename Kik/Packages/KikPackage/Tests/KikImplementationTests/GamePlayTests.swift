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
    
    func test_gameUsing() {
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
    
    
    func test_gamePlay_combinationLeftCenter() {
        GamePlay(gameState: kikAPI.newGame())
            .move(.leftTop)
            .move(.centerTop)
            .move(.leftCenter)
            .move(.centerCenter)
            .move(.leftBottom)
            .assertSnapshot("1_X_winning_State")
            .assertWonByPlayer(.x)
            
            .move()
            .assertSnapshot("2_new_game")
            .assertPlayer(.o)
    }
}

struct GamePlay {
    let gameState: MoveResult
    
    @discardableResult
    func move(_ pos: CellPosition = .leftTop) -> GamePlay {
        switch gameState {
        case .playerXMove(_, let nextMoves):
            let move = nextMoves |> nextMoveCapability(pos)
            
            return GamePlay(gameState: move())
            
        case .playerOMove(_, let nextMoves):
            let move = nextMoves |> nextMoveCapability(pos)
            
            return GamePlay(gameState: move())
            
        case .gameWon(_, _, let move):
            return GamePlay(gameState: move())
            
        case .gameTie(_, let move):
            return GamePlay(gameState: move())
        }
    }
    
    @discardableResult
    func assertSnapshot(
        _ name: String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        testName: String = #function) -> GamePlay {
        
        let displayInfo: DisplayInfo!
        switch gameState {
        case .playerXMove(let info, _): displayInfo = info
        case .playerOMove(let info, _): displayInfo = info
        case .gameWon(let info, _, _) : displayInfo = info
        case .gameTie(let info, _)    : displayInfo = info
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
        case .gameWon(_, let player, _):
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
            XCTAssertEqual(1, count, message(), file: file, line: line)
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
