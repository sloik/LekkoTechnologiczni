import Foundation
import KikDomain
import FunctionalAPI

@testable import KikImplementation

func playedState(in game: GameState, for player: Player) -> (Line) -> GameState {
    { (line: Line) in
        line
            .cellsPositions
            .reduce(into: game) { ( game: inout GameState, pos: CellPosition) in
                let cellWithPalyer = Cell(pos: pos, state: .played(player))
                
                let updatedGame = updateCell(cellWithPalyer)(game)
                
                game = updatedGame
            }
    }
}

let emptyGameState = GameState(cells: allEmptyCells)

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

func toString(_ line: Line) -> String {
    """
    Line:
    \t\( line.cellsPositions.map(toString) )
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
    "CellPosition: H:\( toAscii(pos.hp) ) V:\( toAscii(pos.vp) )"
}

func toString(_ state: CellState) -> String {
    switch state {
    case .played(let player): return "State: [\(player)]"
    case              .empty: return "State: [ ]"
    }
}

func toAscii(_ hp: HorizPosition) -> String {
    switch hp {
    case    .left: return "←"
    case .hCenter: return "|"
    case   .right: return "→"
    }
}

func toAscii(_ vp: VertPosition) -> String {
    switch vp {
    case     .top: return "↑"
    case .vCenter: return "-"
    case  .bottom: return "↓"
    }
}

func toAscii(_ game: GameState) -> String {
    let getPos = getCell(game)
    
    return """
    \( toString(getPos (CellPosition(hp: .left, vp: .top)).state)     ) | \( toString(getPos (CellPosition(hp: .hCenter, vp: .top)).state)     ) | \( toString(getPos (CellPosition(hp: .right, vp: .top)).state)     )
    \( toString(getPos (CellPosition(hp: .left, vp: .vCenter)).state) ) | \( toString(getPos (CellPosition(hp: .hCenter, vp: .vCenter)).state) ) | \( toString(getPos (CellPosition(hp: .right, vp: .vCenter)).state) )
    \( toString(getPos (CellPosition(hp: .left, vp: .bottom)).state)  ) | \( toString(getPos (CellPosition(hp: .hCenter, vp: .bottom)).state)  ) | \( toString(getPos (CellPosition(hp: .right, vp: .bottom)).state)  )
    """
}
