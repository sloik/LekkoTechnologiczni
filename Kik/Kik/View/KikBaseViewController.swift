import UIKit
import ReSwift

class KikBaseViewController: UIViewController{
    
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainStore.subscribe(self)
        mainStore.dispatch(KikActions.resetGame)
        addAccesibilityIdentifiers()
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        mainStore.dispatch(KikActions.tapAction(sender.tag))
        mainStore.dispatch(KikActions.setupGrid)
        switch mainStore.state.gameState {
        case .winner:            
            showWinner()
        case .tie:
            showTie()
        case .playing:
            break
        }
    }
}

extension KikBaseViewController {
    
    private func showWinner() {
        let ok = UIAlertAction(title: "New Game",
                               style: UIAlertAction.Style.default) { _ in
                                mainStore.dispatch(KikActions.resetGame)
                                
        }
        
        let alert = UIAlertController(title: "🤩 Game won by" ,
                                      message: mainStore.state.grid,
                                      preferredStyle: .alert)
        
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showTie() {
        let ok = UIAlertAction(title: "New Game",
                               style: UIAlertAction.Style.default) { _ in
                                mainStore.dispatch(KikActions.resetGame)
        }
        
        let alert = UIAlertController(title: "🤔 No one won!" ,
                                      message: mainStore.state.grid,
                                      preferredStyle: .alert)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

extension KikBaseViewController: StoreSubscriber {
    
    func newState(state: KikState) {
        buttons.forEach {
            button in
            button.setTitle(mainStore.state.model[button.tag].rawValue, for: .normal)
        }
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
