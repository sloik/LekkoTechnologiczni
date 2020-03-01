
import Foundation

extension Optional {
    var isSome: Bool {
        switch self {
        case .none: return false
        case .some: return true
        }
    }

    var isNone: Bool { !self.isSome }
}

enum Symbol: String, CaseIterable, Equatable {
    case X = "X"
    case O = "O"
    case none = "-"
}

enum GameStateResult: Equatable {
    case winner
    case tie
    case playing
}

extension Symbol {
    var isNone: Bool {
         Symbol.none == self
    }

    var oposite: Symbol {
        switch self {
        case    .X: return .O
        case    .O: return .X
        case .none: return .none
        }
    }
}

struct Line {
    let x: Int
    let y: Int
    let z: Int

    static let lines: [Line] = [
          .topRow, .midRow, .bottomRow,
          .leftColumn, .midColumn, .rightColumn,
          .diagonal1, .diagonal2
      ]
}

extension Line {
    static var    topRow: Line { Line(x: 0, y: 1, z: 2) }
    static var    midRow: Line { Line(x: 3, y: 4, z: 5) }
    static var bottomRow: Line { Line(x: 6, y: 7, z: 8) }

    static var  leftColumn: Line { Line(x: 0, y: 3, z: 6) }
    static var   midColumn: Line { Line(x: 1, y: 4, z: 7) }
    static var rightColumn: Line { Line(x: 2, y: 5, z: 8) }

    static var diagonal1: Line { Line(x: 0, y: 4, z: 8) }
    static var diagonal2: Line { Line(x: 2, y: 4, z: 6) }
}
