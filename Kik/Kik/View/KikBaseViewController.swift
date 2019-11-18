
import UIKit

class KikBaseViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    var viewModel = KikViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGame()
        addAccesibilityIdentifiers()
    }

    func setupGame() {
        viewModel.resetGame()
        refreshButtons()

        viewModel.delegate = self
    }

    func refreshButtons() {
      buttons
        .forEach { button in
            button.setTitle(viewModel.title(for: button.tag),
                            for: .normal)
        }
    }

    @IBAction func didTapButton(_ sender: UIButton) {
        viewModel.didTapElement(sender.tag)
        refreshButtons()
    }
}

extension KikBaseViewController: KikViewModelDelegate {
    func showAlert(title: String, message: String) {
        let ok = UIAlertAction(title: "New Game",
        style: UIAlertAction.Style.default) { _ in
            self.setupGame()
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
