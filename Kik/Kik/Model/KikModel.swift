
import Foundation


enum Symbol: CaseIterable, Equatable {
    case X
    case O
    case none
}

enum GameStateResult: Equatable {
    case winner(Symbol)
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

struct KikModel {
    private(set) var currentSymbol: Symbol = .O

    let lines: [Line] = [
        .topRow, .midRow, .bottomRow,
        .leftColumn, .midColumn, .rightColumn,
        .diagonal1, .diagonal2
    ]

    private(set) var gameState: [Symbol] = Array(repeating: .none, count: 9)

    var hasEmptyElement: Bool { gameState.contains(.none) }

    var grid: [Line] {
        [.topRow, .midRow, .bottomRow]
    }

    mutating func resetGame() {
        gameState = Array(repeating: .none, count: 9)
    }

    mutating func didTapElement(_ index: Int) -> GameStateResult {
        let tappedSymbol = gameState[index]
        guard tappedSymbol.isNone else { return .playing }

        gameState[index] = currentSymbol

        defer { currentSymbol = currentSymbol.oposite }

        return gameEnded()
    }

    private func gameEnded() -> GameStateResult {
        let hasSameSymbolInLine = lines.first(where: allSymbolsAreTheSame(line:)).isSome

        switch (hasSameSymbolInLine, hasEmptyElement) {
        case (true, _)  : return .winner(currentSymbol)
        case (_ , false): return .tie
        default         : return .playing
        }
    }

    func allSymbolsAreTheSame(line: Line) -> Bool {
        let symbolLine = lineToSymbols(line)

        if symbolLine.contains(.none) {
            return false
        }

        let symbolSet: Set<Symbol> = Set(symbolLine)
        return symbolSet.count == 1
    }

    func lineToSymbols(_ line: Line) -> [Symbol] {
        [ gameState[line.x], gameState[line.y], gameState[line.z] ]
    }

    func symbol(at index: Int) -> Symbol {
        gameState[index]
    }
}

extension Optional {
    var isSome: Bool {
        switch self {
        case .none: return false
        case .some: return true
        }
    }

    var isNone: Bool { !self.isSome }
}
