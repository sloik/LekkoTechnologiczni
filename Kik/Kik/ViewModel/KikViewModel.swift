import Foundation

protocol KikViewModelDelegate {
    func showAlert(title: String, message: String)
}

struct KikViewModel {
    private var model: KikModel
    var delegate: KikViewModelDelegate?

    var grid: String {
        model
            .grid
            .map(model.lineToSymbols(_:)) // .X, .O, .none
            .map { (symbols: [Symbol]) in // [.X, .O, .none]
                symbols
                    .map(string(for:)) // ["X", "O", "-"]
                    .joined(separator: " ") } // "X O -"
            .joined(separator: "\n")
    }

    internal init(model: KikModel = KikModel()) {
        self.model = model
        
    }

    func string(for symbol: Symbol) -> String {
        switch symbol {
        case .X: return "X"
        case .O: return "O"
        case .none: return "-"
        }
    }
}

extension KikViewModel {
    mutating func resetGame() {
        model.resetGame()
    }

    func title(for index: Int) -> String {
        string(for: model.symbol(at: index))
    }

    mutating func didTapElement(_ index: Int) {
        switch model.didTapElement(index) {
        case .winner(let player):
            let title = "🤩 Game won by \(string(for: player))"
            delegate?.showAlert(title: title, message: grid)
        case .tie:
            delegate?.showAlert(title: "🤔 No one won!" , message: grid)
        case .playing:
            break
        }
    }
}
