// https://gist.github.com/swlaschin/7a5233a91912e66ac1e4
// https://fsharpforfunandprofit.com/posts/enterprise-tic-tac-toe/
// ENTERPRISE TIC-TAC-TOE - Scott Wlaschin https://vimeo.com/131658142

import Foundation
import KikDomain
import Prelude
import OptionalAPI

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

struct Line: Equatable {
    let cellsPositions: [CellPosition]
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
            |> Line.init(cellsPositions:)
    }

    let horizontalLines: [Line] = VertPosition.allCases.map(makeHLine)

    // Makes a vertical line for horizontal index
    // eg. left -> Line{ (left, top), (left, vCenter), (left, bottom) }
    let makeVLine: (HorizPosition) -> Line = { h in
        VertPosition
            .allCases
            .map { v in (h, v) }
            .map( CellPosition.init(hp:vp:) )
            |> Line.init(cellsPositions:)
    }

    let verticalLines: [Line] = HorizPosition.allCases.map(makeVLine)

    let diagonalLine1: Line = [(HorizPosition.left, VertPosition.top), (.hCenter, .vCenter), (.right, .bottom)]
        .map( CellPosition.init(hp:vp:) )
        |> Line.init(cellsPositions:)

    let diagonalLine2: Line = [(.left, .bottom), (.hCenter, .vCenter), (.left, .top)]
        .map( CellPosition.init(hp:vp:) )
        |> Line.init(cellsPositions:)

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

let getCell: (GameState) -> (CellPosition) -> Cell =
    { (gameState: GameState) in
        { (posToFind: CellPosition) -> Cell in

            gameState
                .cells
                .first { (cell: Cell) -> Bool in
                    cell.pos == posToFind
                }!
        }
    }


/// update a particular cell in the GameState
   /// and return a new GameState
//   let private updateCell newCell gameState =


/// This function given current game state and a cell will return a new game state with
/// the cell "inserted" in the correct place.
private let updateCell = {  (newCell: Cell , gameState: GameState ) -> GameState in
    gameState
        .cells
        .map { (cell: Cell) -> Cell in
            cell.pos == newCell.pos // if the current cell is in place of the new one
                ? newCell           // return the new one
                : cell              // return original one
        }
        |> GameState.init(cells:)
}


/// Return true if the game was won by the specified player
//   let private isGameWonBy player gameState =

private let isGameWonBy = { (player: Player, gameState: GameState) -> Bool in

    func cellWasPlayed(by playerToCheck: Player) -> (Cell) -> Bool {
        { (cell: Cell) -> Bool in

            switch cell.state {
            case .played(let player):
                return playerToCheck == player

            case .empty:
                return false
            }
        }
    }

    func lineIsAllSame(_ player: Player) -> (Line) -> Bool {
        { (line: Line) in
            line
                .cellsPositions
                // getCell(gameState) return a function "waiting" for cell position.
                .map( getCell(gameState) )
                // Here we have the cells from that line as they are currently played.
                .allSatisfy( cellWasPlayed(by: player) )
        }
    }

    return
        linesToCheck
            .first(where: lineIsAllSame(player) )
            .isSome
}



/// Return true if all cells have been played
//    let private isGameTied gameState =

let isGameTied = { (gameState: GameState) -> Bool in

    let cellWasPlayed = { (cell: Cell) -> Bool in
        switch cell.state {
        case .played: return true
        case .empty: return false
        }
    }

    return gameState.cells.allSatisfy( cellWasPlayed )
}
