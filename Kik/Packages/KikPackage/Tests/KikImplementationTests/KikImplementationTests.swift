
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
        linesToCheck
            .map( String.init(describing:) )
            .forEach { line in
                assertSnapshot(matching: line, as: Snapshotting<String, String>.lines)
            }
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

}


let allPositions: [CellPosition] =
    product(
        HorizPosition.allCases,
        VertPosition.allCases
    )
    .map(CellPosition.init(hp:vp:))


let allEmptyCells: [Cell] = allPositions
    .map { pos in Cell(pos: pos, state: .empty)  }

let allXCells: [Cell] = allPositions.map { pos in Cell(pos: pos, state: .played(.x)) }

let repeatedCells: [Cell] = allPositions
    .enumerated()
    .map{ (index, pos) in
        switch index % 3 {
        case 0: return Cell(pos: pos, state: .empty)
        case 1: return Cell(pos: pos, state: .played(.x))
        case 2: return Cell(pos: pos, state: .played(.o))
        default:
            fatalError()
        }
    }

func toString(_ gameState: GameState) -> String {
    """
    GameState>
    \(gameState.cells.map( toString ).joined(separator: "\n"))
    """
}

func toString(_ cell: Cell) -> String {
    """
    Cell:
    \t\(toString(cell.pos)),
    \t       \(toString(cell.state))
    """
}

func toString(_ pos: CellPosition) -> String {
    "CellPosition: H:\(pos.hp) V:\(pos.vp)"
}

func toString(_ state: CellState) -> String {
    switch state {
    case .played(let player): return "State: [\(player)]"
    case              .empty: return "State: []"
    }
}
