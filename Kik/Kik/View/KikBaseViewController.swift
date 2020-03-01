import ReSwift
import UIKit

class KikBaseViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]!

    override func viewDidLoad() {
        super.viewDidLoad()
        mainStore.subscribe(self)
        mainStore.dispatch(KikActions.resetGame)
        addAccesibilityIdentifiers()
    }

    @IBAction func didTapButton(_ sender: UIButton) {
        mainStore.dispatch(KikActions.tapAction(sender.tag))
        mainStore.dispatch(KikActions.showGrid)

        switch mainStore.state.gameStateResult {
        case .winner:
            showAlert(title: "🤩 Game won by \(mainStore.state.currentSymbol.oposite)", message: mainStore.state.grid)
        case .tie:
            showAlert(title: "🤔 No one won!", message: mainStore.state.grid)
        case .playing:
            break
        }
    }
}

extension KikBaseViewController {

    func showAlert(title: String, message: String) {
        let ok = UIAlertAction(title: "New Game",
                               style: UIAlertAction.Style.default) { _ in
                                mainStore.dispatch(KikActions.resetGame)
        }

        let alert = UIAlertController(title: title ,
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

extension KikBaseViewController {
    
    func addAccesibilityIdentifiers() {
        for button in buttons {
            button.isAccessibilityElement = true
            button.accessibilityIdentifier = String(button.tag)
        }
    }
}

extension KikBaseViewController: StoreSubscriber {

    func newState(state: KikState){
        buttons.forEach {
            $0.setTitle(mainStore.state.model[$0.tag].rawValue, for: .normal)
        }
    }
}
