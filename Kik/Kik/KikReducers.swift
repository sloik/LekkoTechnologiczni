import ReSwift

func kikReducer(action: Action, state:KikState?) -> KikState {
    
    var state = state ?? KikState()
    
    guard let action = action as? KikActions else {
        return state
    }
    
    switch action {
    case .tapAction(let index):
        print("dupa")

        let tappedSymbol = state.model[index]
        
        guard tappedSymbol.isNone else {return state }
        
        state.model[index] = state.currentSymbol
        
        defer { state.currentSymbol = state.currentSymbol.oposite }
        
        state.gameState = gameEnded(symbols: state.model)
        
    case .resetGame:
        state.model = Array(repeating: .none, count: 9)
        
    }
    
    
    return state
}

let lines: [Line] = [
    .topRow,.midRow, .bottomRow,
    .leftColumn, .midColumn, .rightColumn,
    .diagonal1, .diagonal2
]

private func gameEnded(symbols: [Symbol]) -> GameStateResult {
    
    var hasEmptyElement: Bool { symbols.contains(.none) }
    
    //        let hasSameSymbolInLine = lines.first(where:allSymbolsAreTheSame(line:)).isSome
    
    let symbolInLine = lines.map {
        line in
        allSymbolsAreTheSame(line: line, symbols: symbols)
    }.filter {
        $0 == true
    }.first
    
 
    
    switch (symbolInLine, hasEmptyElement) {
    case (true, _) : return .winner
    case (_, false): return .tie
    default        : return .playing
    }
    
}


private func allSymbolsAreTheSame(line: Line, symbols: [Symbol]) -> Bool {
    let symbolLine = lineToSymbols(line, symbols:symbols)
    if symbolLine.contains(.none) {
        return false
    }
    
    let symbolSet: Set<Symbol> = Set(symbolLine)
    return symbolSet.count == 1
}

private func lineToSymbols(_ line: Line, symbols: [Symbol] ) -> [Symbol] {
    [ symbols[line.x],
      symbols[line.y],
      symbols[line.z] ]
}

