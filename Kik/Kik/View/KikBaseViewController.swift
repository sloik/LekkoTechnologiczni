import UIKit
import ReSwift

class KikBaseViewController: UIViewController, StoreSubscriber {
    
    typealias StoreSubscriberStateType = KikState
    
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // REDUX
        mainStore.subscribe(self)
        
        setupGame()
        addAccesibilityIdentifiers()
    }
    //REDUX
    func newState(state: KikState) {
        
        
    }
    
    func setupGame() {
        mainStore.dispatch(KikActions.resetGame)
        refreshButtons()
    }
    
    
    @IBAction func didTapButton(_ sender: UIButton) {
        mainStore.dispatch(KikActions.tapAction(sender.tag))
        switch mainStore.state.gameState {
        case .winner:
            showWinner()
        case .tie:
            showTie()
        case .playing:
            break
        }
        refreshButtons()
        
    }
    
    func refreshButtons() {
        buttons.forEach {
            button in
            button.setTitle(mainStore.state.model[button.tag].rawValue, for: .normal)
        }
    }
}

extension KikBaseViewController {
    
    func showWinner() {
        let ok = UIAlertAction(title: "New Game",
                               style: UIAlertAction.Style.default) { _ in
                                self.setupGame()
        }
        
        let alert = UIAlertController(title: "🤩 Game won by" ,
                                      message: "DUPAKI TO IMPLEMENT",
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
                                      message: "DUPAKI TO IMPLEMENT",
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
