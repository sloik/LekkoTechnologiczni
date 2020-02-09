import ReSwift

struct KikState: StateType {
    
    var currentSymbol: Symbol = .O
    var model: [Symbol] = Array(repeating: .none, count: 9)
    var gameState: GameStateResult = .playing
}
