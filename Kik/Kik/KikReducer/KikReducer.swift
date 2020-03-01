import ReSwift
import Foundation

func kikReducer(action: Action, state: KikState?) -> KikState {

    var state = state ?? KikState()

    guard let action = action as? KikActions else {
        return state
    }

    switch action {

    case .tapAction(let index):

        let tappedSymbol = state.model[index]
        guard tappedSymbol.isNone else { return state}

        state.model[index] = state.currentSymbol

        defer { state.currentSymbol = state.currentSymbol.oposite}

        state.gameStateResult = gameEnded(symbols: state.model)

    case .resetGame:
        state.model = Array(repeating: .none, count: 9)

    case .showGrid:

        var grid: [Line] {
            [.topRow, .midRow, .bottomRow]
        }

        state.grid = grid
            .compactMap { lineToSymbols($0, symobols: state.model)}
            .compactMap { $0.map {$0.rawValue}.joined(separator: "")}
            .joined(separator: "\n")
    }


    return state
}


private func gameEnded(symbols: [Symbol]) -> GameStateResult {

    var hasEmptyElement: Bool {symbols.contains(.none)}

    var hasSameSymbolInLine = Line.lines.map {
        allSymbolsAreTheSame(line: $0, symbols: symbols)
    }.filter { $0 == true }.first


    switch (hasSameSymbolInLine, hasEmptyElement) {
    case (true, _)  : return .winner
    case (_ , false): return .tie
    default         : return .playing
    }
}


private func allSymbolsAreTheSame(line: Line, symbols: [Symbol] ) -> Bool {
    let symbolLine = lineToSymbols(line, symobols: symbols)

    if symbolLine.contains(.none) {
        return false
    }

    let symbolSet: Set<Symbol> = Set(symbolLine)
    return symbolSet.count == 1
}


private func lineToSymbols(_ line: Line, symobols: [Symbol]) -> [Symbol] {
    [ symobols[line.x],
      symobols[line.y],
      symobols[line.z] ]
}
