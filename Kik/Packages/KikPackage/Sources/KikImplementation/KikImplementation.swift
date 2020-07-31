
import Foundation
import KikDomain
import Prelude

// private implementation of game state
struct GameState {
    let cells: [Cell]
}


/// the list of all horizontal positions
let allHorizPositions: [HorizPosition] = HorizPosition.allCases


/// the list of all horizontal positions
let allVertPositions: [VertPosition] = VertPosition.allCases


/// A type to store the list of cell positions in a line
//    type Line = Line of CellPosition list

struct Line {
    let cells: [CellPosition]
}


/// a list of the eight lines to check for 3 in a row
let linesToCheck: [Line] = {

    // Makes a horizontal line for vertical index
    // eg. top -> Line{ (left, top), (hCenter, top), (right, top) }
    let makeHLine: (VertPosition) -> Line = { v in
        HorizPosition
            .allCases               // left     ...  hCenter    ...  right
            .map { h in (h, v) }    // (left, v)... (hCenter, v)... (right, v)
            .map ( CellPosition.init(hp: vp:) ) // CP{left, v}... CP{hCenter, v)
            |> Line.init(cells:)
    }

    let horizontalLines: [Line] = VertPosition.allCases.map(makeHLine)

    // Makes a vertical line for horizontal index
    // eg. left -> Line{ (left, top), (left, vCenter), (left, bottom) }
    let makeVLine: (HorizPosition) -> Line = { h in
        VertPosition
            .allCases
            .map { v in (h, v) }
            .map( CellPosition.init(hp:vp:) )
            |> Line.init(cells:)
    }

    let verticalLines: [Line] = HorizPosition.allCases.map(makeVLine)

    let diagonalLine1: Line = [(HorizPosition.left, VertPosition.top), (.hCenter, .vCenter), (.right, .bottom)]
        .map( CellPosition.init(hp:vp:) )
        |> Line.init(cells:)

    let diagonalLine2: Line = [(.left, .bottom), (.hCenter, .vCenter), (.left, .top)]
        .map( CellPosition.init(hp:vp:) )
        |> Line.init(cells:)

    return horizontalLines + horizontalLines + [diagonalLine2]
}()


/// get the DisplayInfo from the gameState
//let getDisplayInfo gameState =
//    {DisplayInfo.cells = gameState.cells}

// We can write it...
//let getDisplayInfo: (GameState) -> DisplayInfo = { gameState in
//    DisplayInfo(cells: gameState.cells)
//}

// Or we can compose it!
let getDisplayInfo: (GameState) -> DisplayInfo =
    ^\GameState.cells >>> DisplayInfo.init(cells:)


/// get the cell corresponding to the cell position
//    let getCell gameState posToFind =
//        gameState.cells
//        |> List.find (fun cell -> cell.pos = posToFind)

let getCell = { (gameState: GameState, posToFind: CellPosition) -> Cell in
    gameState
        .cells
        .first { (cell: Cell) -> Bool in
            cell.pos == posToFind
        }!
}


/// update a particular cell in the GameState
   /// and return a new GameState
//   let private updateCell newCell gameState =
#error("Start here...")
