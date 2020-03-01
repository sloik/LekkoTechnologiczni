import ReSwift
import Foundation

struct KikState: StateType {

    var currentSymbol: Symbol = .O
    var model: [Symbol] = Array(repeating: .none, count: 9)
    var gameStateResult: GameStateResult = .playing
    var grid: String = ""
    
}
