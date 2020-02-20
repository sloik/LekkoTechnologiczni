import UIKit
import ReSwift

class KikBaseViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var slider: UISlider! {
        didSet {
            slider.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MainStore.subscribe(self)

        addAccesibilityIdentifiers()
    }

    @IBAction func didTapButton(_ sender: UIButton) {
        MainStore
            .dispatch(
                UserActions.didTap(sender.tag)
        )
    }

    
}

extension KikBaseViewController {
    func show(winner: String, grid: String) {
        let ok = UIAlertAction(title: "New Game",
                               style: UIAlertAction.Style.default) { _ in
                                MainStore
                                    .dispatch(
                                        UserActions.resetGame
                                )
        }

        let alert = UIAlertController(title: "🤩 Game won by \(winner)" ,
                          message: grid,
                          preferredStyle: .alert)

        alert.addAction(ok)

        present(alert, animated: true, completion: nil)
    }

    func showTie(grid: String) {
        let ok = UIAlertAction(title: "New Game",
                               style: UIAlertAction.Style.default) { _ in
                                MainStore
                                    .dispatch(
                                        UserActions.resetGame
                                )
        }

        let alert = UIAlertController(title: "🤔 No one won!" ,
                          message: grid,
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
    
    func newState(state: KikState) {
        presentedViewController
            .map({ vc in vc.dismiss(animated: true, completion: nil) })
        
        switch state.viewState {

        case .show(let winner, let grid):
            show(winner: winner, grid: grid)
            
        case .showTie(let grid):
            showTie(grid: grid)
            
        case .showBoard:
            presentedViewController
                .map({ vc in vc.dismiss(animated: true, completion: nil) })
        }
        
        // reset button
        buttons.forEach { button in
            button.setTitle(state.game.model[button.tag].rawValue, for: .normal)
        }
    }
    
}

// MARK: - Slider

extension KikBaseViewController {
    @IBAction func didSlide(_ sender: UISlider) {
        MainStore
            .dispatch(
                HistoryActions
                    .restore(index: Int(sender.value))
        )
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?){
        if motion == .motionShake {
            slider.isHidden.toggle()
        }
    }
}
