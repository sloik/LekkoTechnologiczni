
import UIKit

enum Symbol: String {
    case X    = "X"
    case O    = "O"
    case none = "-"
}

enum GameStateResult {
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

class KikBaseViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]!

    let lineIndexes = [
        [0,1,2],
        [3,4,5],
        [6,7,8],

        [0,3,6],
        [1,4,7],
        [2,5,8],

        [0,4,8],
        [2,4,6]
    ]

    var currentSymbol: Symbol = .O
    var model: [Symbol] = Array(repeating: .none, count: 9)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGame()
        addAccessibilityIdentifiers()
    }

    func setupGame() {
        model = Array(repeating: .none, count: 9)

        for button in buttons {
            button.setTitle(Symbol.none.rawValue, for: .normal)
        }
    }


    @IBAction func didTapButton(_ sender: UIButton) {
        let tappedSymbol = model[sender.tag]

        guard tappedSymbol.isNone else { return }

        sender.setTitle(currentSymbol.rawValue, for: .normal)
        model[sender.tag] = currentSymbol

        switch gameEnded() {
        case  .winner: showWinner()
        case     .tie: showTie()
        case .playing: break
        }

        currentSymbol = currentSymbol.oposite
    }

    func gameEnded() -> GameStateResult {
        var linesOfSymbols: [[Symbol]] = []

        for line in lineIndexes {
            let symbolLine = convertLinesToSymbols(line: line)
            linesOfSymbols.append(symbolLine)
        }

        for symbolLine in linesOfSymbols {
            if checkIfAllSymbolsAreTheSame(symbolLine: symbolLine) {
                return .winner
            }
        }

        if model.contains(.none) == false {
            return .tie
        }

        return .playing
    }

    func checkIfAllSymbolsAreTheSame(symbolLine: [Symbol]) -> Bool {
        if symbolLine.contains(.none) {
            return false
        }

        let symbolSet: Set<Symbol> = Set(symbolLine)
        return symbolSet.count == 1
    }

    func convertLinesToSymbols(line: [Int]) -> [Symbol] {
        var symbols: [Symbol] = []

        for index in line {
            symbols.append(model[index])
        }

        return symbols
    }

    func showWinner() {
        let ok = UIAlertAction(title: "New Game",
        style: UIAlertAction.Style.default) { _ in
            self.setupGame()
        }

        let alert = UIAlertController(title: "🤩 Game won by \(currentSymbol.rawValue)" ,
                          message: grid,
                          preferredStyle: .alert)

        alert.addAction(ok)

        present(alert, animated: true, completion: nil)
    }

    func showTie() {
        let ok = UIAlertAction(title: "New Game",
        style: UIAlertAction.Style.default) { _ in
            self.setupGame()
        }

        let alert = UIAlertController(title: "🤔 No one won!" ,
                          message: grid,
                          preferredStyle: .alert)

        alert.addAction(ok)

        present(alert, animated: true, completion: nil)
    }

    var grid: String {
        """
        \(model[0].rawValue)  \(model[1].rawValue)  \(model[2].rawValue)
        \(model[3].rawValue)  \(model[4].rawValue)  \(model[5].rawValue)
        \(model[6].rawValue)  \(model[7].rawValue)  \(model[8].rawValue)
        """
    }
}

extension KikBaseViewController {
    
    func addAccessibilityIdentifiers() {
        for button in buttons {
            button.isAccessibilityElement = true
            button.accessibilityIdentifier = String(button.tag)
        }
    }
}
