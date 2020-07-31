// https://gist.github.com/swlaschin/7a5233a91912e66ac1e4
// https://fsharpforfunandprofit.com/posts/enterprise-tic-tac-toe/
// ENTERPRISE TIC-TAC-TOE - Scott Wlaschin https://vimeo.com/131658142

import Foundation

public enum HorizPosition: CaseIterable, Equatable {
    case left, hCenter, right
}

public enum VertPosition: CaseIterable, Equatable {
    case top, vCenter, bottom
}

public struct CellPosition: Equatable {
    let hp: HorizPosition
    let vp: VertPosition

    public init(hp: HorizPosition, vp: VertPosition) {
        self.hp = hp
        self.vp = vp
    }
}

public enum Player: Equatable {
    case x, o
}

public enum CellState: Equatable {
    case played(Player)
    case empty
}

public struct Cell: Equatable {
    public let pos: CellPosition
    public let state: CellState
}


///// Everything the UI needs to know to display the board
//    type DisplayInfo = {
//        cells : Cell list
//        }

public struct DisplayInfo {
    let cells: [Cell]

    public init(cells: [Cell]) {
        self.cells = cells
    }
}


/// The capability to make a move at a particular location.
/// The gamestate, player and position are already "baked" into the function.
//type MoveCapability =
//    unit -> MoveResult

typealias MoveCapability = () -> MoveResult


/// A capability along with the position the capability is associated with.
/// This allows the UI to show information so that the user
/// can pick a particular capability to exercise.
//and NextMoveInfo = {
//    // the pos is for UI information only
//    // the actual pos is baked into the cap.
//    posToPlay : CellPosition
//    capability : MoveCapability }

struct NextMoveInfo {
    let posToPlay: CellPosition
    let capability: MoveCapability
}


/// The result of a move. It includes:
/// * The information on the current board state.
/// * The capabilities for the next move, if any.
//and MoveResult =
//    | PlayerXToMove of DisplayInfo * NextMoveInfo list
//    | PlayerOToMove of DisplayInfo * NextMoveInfo list
//    | GameWon of DisplayInfo * Player
//    | GameTied of DisplayInfo

enum MoveResult {
    case playerXMove(DisplayInfo, [NextMoveInfo])
    case playerOMove(DisplayInfo, [NextMoveInfo])
    case gameWon(DisplayInfo, Player)
    case gameTie(DisplayInfo)
}

// Only the newGame function is exported from the implementation
   // all other functions come from the results of the previous move
//   type TicTacToeAPI  =
//       {
//       newGame : MoveCapability
//       }

struct KikAPI {
    let newGame: MoveCapability
}
