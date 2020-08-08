// https://gist.github.com/swlaschin/7a5233a91912e66ac1e4
// https://fsharpforfunandprofit.com/posts/enterprise-tic-tac-toe/
// ENTERPRISE TIC-TAC-TOE - Scott Wlaschin https://vimeo.com/131658142

import Foundation


/// Defines what is a horizontal position.
public enum HorizPosition: String, CaseIterable, Equatable {
    case left, hCenter, right
}


/// Defines what is a vertical position.
public enum VertPosition: String, CaseIterable, Equatable {
    case top, vCenter, bottom
}


/// Cell Position consists of a Horizontal and Vertical Position.
public struct CellPosition: Equatable {

    /// Horizontal component of the position.
    public let hp: HorizPosition

    /// Vertical component of the position
    public let vp: VertPosition

    public init(hp: HorizPosition, vp: VertPosition) {
        self.hp = hp
        self.vp = vp
    }
    
    public static var   leftTop: CellPosition { .init(hp: .left,    vp: .top) }
    public static var centerTop: CellPosition { .init(hp: .hCenter, vp: .top) }
    public static var  rightTop: CellPosition { .init(hp: .right,   vp: .top) }
    
    public static var   leftCenter: CellPosition { .init(hp: .left,     vp: .vCenter) }
    public static var centerCenter: CellPosition { .init(hp: .hCenter,  vp: .vCenter) }
    public static var  rightCenter: CellPosition { .init(hp: .right,    vp: .vCenter) }
    
    public static var   leftBottom: CellPosition { .init(hp: .left,     vp: .bottom) }
    public static var centerBottom: CellPosition { .init(hp: .hCenter,  vp: .bottom) }
    public static var  rightBottom: CellPosition { .init(hp: .right,    vp: .bottom) }
}

/// Defines posible players.
public enum Player: Equatable, CaseIterable {
    case x, o
}


/// Cell can be in two possible states. Either it was played by a `Player` or it's `empty`.
public enum CellState: Equatable {
    case played(Player)
    case empty
}


/// Definition of a `Cell` in a game.
public struct Cell: Equatable {

    /// Position of the cell.
    public let pos: CellPosition

    /// Was the cell already played by `Player` or is `empty`.
    public let state: CellState

    public init(pos: CellPosition, state: CellState) {
        self.pos = pos
        self.state = state
    }
}


/// Everything the UI needs to know to display the board
public struct DisplayInfo {

    // List of `Cell`s. Each one has the position and state information.
    public let cells: [Cell]

    public init(cells: [Cell]) {
        self.cells = cells
    }
}


/// The capability to make a move at a particular location.
/// The game state, player and position are already "baked" into the function.
public typealias MoveCapability = () -> MoveResult


/// A capability along with the position the capability is associated with.
/// This allows the UI to show information so that the user
/// can pick a particular capability to exercise.
public struct NextMoveInfo {
    public let posToPlay: CellPosition
    public let capability: MoveCapability

    public init(posToPlay: CellPosition, capability: @escaping MoveCapability) {
        self.posToPlay = posToPlay
        self.capability = capability
    }
}

/// The result of a move.
///
/// It includes:
/// * The information on the current board state.
/// * The capabilities for the next move, if any.
public enum MoveResult {
    case playerXMove(DisplayInfo, [NextMoveInfo])
    case playerOMove(DisplayInfo, [NextMoveInfo])
    case gameWon(DisplayInfo, Player)
    case gameTie(DisplayInfo)
}
