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
private let updateCell = {  (newCell: Cell) -> (GameState) -> GameState in
    { (gameState: GameState) in
        gameState
            .cells
            .map { (cell: Cell) -> Cell in
                cell.pos == newCell.pos // if the current cell is in place of the new one
                    ? newCell           // return the new one
                    : cell              // return original one
            }
            |> GameState.init(cells:)
    }
}


/// Return true if the game was won by the specified player
//   let private isGameWonBy player gameState =

private let isGameWonBy = { (player: Player) -> (GameState) -> Bool in
    { (gameState: GameState) in

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


/// determine the remaining moves
//    let private remainingMoves gameState =

private let remainingMoves = { (gameState: GameState) -> [CellPosition] in

    let playableCell = { (cell: Cell) -> CellPosition? in
        switch cell.state {
        case .played: return .none
        case .empty: return cell.pos
        }
    }

    return gameState.cells.compactMap(playableCell)
}


// return the other player
//    let otherPlayer player =

func other(player: Player) -> Player {
    switch player {
    case .x: return .o
    case .o: return .x
    }
}


// return the move result case for a player
//    let moveResultFor player displayInfo nextMoves =

let moveResultFor = { (player: Player, displayInfo: DisplayInfo) ->  ([NextMoveInfo]) -> MoveResult in
    { (nextMoves: [NextMoveInfo]) in
        switch player {
        case .x: return .playerXMove(displayInfo, nextMoves)
        case .o: return .playerOMove(displayInfo, nextMoves)
        }
    }
}


// given a function, a player & a gameState & a position,
// create a NextMoveInfo with the capability to call the function
//let makeNextMoveInfo f player gameState cellPos =
// val makeNextMoveInfo : f:('a -> CellPosition -> 'b -> MoveCapability) -> player:'a -> gameState:'b -> HorizPosition * VertPosition -> NextMoveInfo
//                        f:val ke : ('a -> CellPosition -> 'b -> MoveCapability)

// Given a player, cell position and a game state will produce a function that will create a move capability for it.
typealias PlayerMoveCapabilityProducer = (Player, CellPosition, GameState) -> MoveResult

let makeNextMoveInfo = { (playerMove: @escaping PlayerMoveCapabilityProducer, player: Player, gameState: GameState) -> (CellPosition) -> NextMoveInfo in
    { (cellPos: CellPosition) in

        // This `thunk` just waits to be executed with the the values
        // closed over in a closure.
        let capability: MoveCapability = { () -> MoveResult in
            playerMove(player, cellPos, gameState)
        }

        return NextMoveInfo(posToPlay: cellPos, capability: capability)
    }
}



// given a function (player move???), a player & a gameState & a list of positions,
// create a list of NextMoveInfos wrapped in a MoveResult
// val makeMoveResultWithCapabilities : f:(Player -> CellPosition -> GameState -> MoveResult) -> player:Player -> gameState:GameState -> cellPosList:CellPosition list -> MoveResult
let makeMoveResultWithCapabilities = { (playerMove: @escaping PlayerMoveCapabilityProducer, player: Player, gameState: GameState, cellPosList: [CellPosition]) -> MoveResult in
    let displayInfo = gameState |> getDisplayInfo

    let t =
        cellPosList
        .map{ cp in makeNextMoveInfo(playerMove, player, gameState)(cp) }

    |> moveResultFor(player, displayInfo)

        return .gameTie(displayInfo)
}



// player X or O makes a move
//    let rec playerMove player cellPos gameState  =
//val playerMove : player:Player -> HorizPosition * VertPosition -> gameState:GameState -> MoveResult


func playerMove(player: Player, cellPos: CellPosition, gameState: GameState) -> MoveResult {

    let newCell      = Cell(pos: cellPos, state: .played(player))
    let newGameState = gameState |> updateCell(newCell)
    let displayInfo  = newGameState |> getDisplayInfo

    if newGameState |> isGameWonBy(player) {
        return .gameWon(displayInfo, player)
    }

    if newGameState |> isGameTied {
        return .gameTie(displayInfo)
    }

    let otherPlayer = player |> other(player:)

    let freeCells: [CellPosition] = newGameState |> remainingMoves

    return
        makeMoveResultWithCapabilities(
            playerMove(player:cellPos:gameState:),
            otherPlayer,
            gameState,
            freeCells
        )
}
