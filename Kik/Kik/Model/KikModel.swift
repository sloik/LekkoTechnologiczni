//import Foundation
//
//
//enum GameStateResult {
//    case winner
//    case tie
//    case playing
//}
//
//struct Line {
//    let x: Int
//    let y: Int
//    let z: Int
//}
//
//extension Line {
//    static var   topRow: Line { Line(x: 0, y: 1, z: 2) }
//    static var   midRow: Line { Line(x: 3, y: 4, z: 5) }
//    static var bottomRow: Line { Line(x: 6, y: 7, z: 8) }
//
//    static var  leftColumn: Line { Line(x: 0, y: 3, z: 6) }
//    static var   midColumn: Line { Line(x: 1, y: 4, z: 7) }
//    static var rightColumn: Line { Line(x: 2, y: 5, z: 8) }
//
//    static var diagonal1: Line { Line(x: 0, y: 4, z: 8) }
//    static var diagonal2: Line { Line(x: 2, y: 4, z: 6) }
//}
//
//extension Line {
//    var indexes: [Int] { [self.x, self.y, self.z] }
//}
//
//struct KikModel {
//    private(set) var currentSymbol: Symbol = .O
//
//    let lines: [Line] = [
//        .topRow,.midRow, .bottomRow,
//        .leftColumn, .midColumn, .rightColumn,
//        .diagonal1, .diagonal2
//    ]
//
//    private(set) var model: [Symbol] = Array(repeating: .none, count: 9)
//
//    var hasEmptyElement: Bool { model.contains(.none) }
//
//    var grid: [Line] {
//        [.topRow,
//         .midRow,
//         .bottomRow]
//    }
//
//    mutating func resetGame() {
//        model = Array(repeating: .none, count: 9)
//    }
//
//    mutating func didTapElement(_ index: Int) -> GameStateResult {
//        let tappedSymbol = model[index]
//        guard tappedSymbol.isNone else { return .playing }
//
//        model[index] = currentSymbol
//
//        defer { currentSymbol = currentSymbol.oposite }
//        return gameEnded()
//    }
//
//    func lineToSymbols(_ line: Line) -> [Symbol] {
//        [ model[line.x],
//          model[line.y],
//          model[line.z] ]
//    }
//
//    func gameEnded() -> GameStateResult {
//        /*
//         This might be the first of refactor stage
//         if lines.first(where:allSymbolsAreTheSame(line:)).isSome {
//         return .winner
//         }
//
//         if hasEmptyElement == false { return .tie }
//
//         return .playing
//         */
//
//        let hasSameSymbolInLine = lines.first(where:allSymbolsAreTheSame(line:)).isSome
//
//        switch (hasSameSymbolInLine, hasEmptyElement) {
//        case (true, _) : return .winner
//        case (_, false): return .tie
//        default        : return .playing
//        }
//    }
////
//    func allSymbolsAreTheSame(line: Line) -> Bool {
//        let symbolLine = lineToSymbols(line)
//        if symbolLine.contains(.none) {
//            return false
//        }
//
//        let symbolSet: Set<Symbol> = Set(symbolLine)
//        return symbolSet.count == 1
//    }
//
//    func title(for index: Int) -> String {
//        model[index].rawValue
//    }
//}
//
//extension Optional {
//    var isSome: Bool {
//        switch self {
//        case .none:    return false
//        case .some(_): return true
//        }
//    }
//
//    var isNone: Bool { !self.isSome }
//}
//
