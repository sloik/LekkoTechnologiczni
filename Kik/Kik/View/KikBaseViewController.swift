import UIKit

class KikBaseViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var slider: UISlider! {
        didSet {
            slider.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addAccessibilityIdentifiers()
    }

    @IBAction func didTapButton(_ sender: UIButton) {
        print("🛤", #function, #line)
    }
}

extension KikBaseViewController {
    func show(winner: String, grid: String) {
        let ok = UIAlertAction(title: "New Game",
                               style: UIAlertAction.Style.default)
        { _ in
            print("🛤", #function, #line)
        }

        let alert = UIAlertController(title: "🤩 Game won by \(winner)" ,
                          message: grid,
                          preferredStyle: .alert)

        alert.addAction(ok)

        present(alert, animated: true, completion: nil)
    }

    func showTie(grid: String) {
        let ok = UIAlertAction(title: "New Game",
                               style: UIAlertAction.Style.default)
        { _ in
            print("🛤", #function, #line)
        }

        let alert = UIAlertController(title: "🤔 No one won!" ,
                          message: grid,
                          preferredStyle: .alert)

        alert.addAction(ok)

        present(alert, animated: true, completion: nil)
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

// MARK: - Slider

extension KikBaseViewController {
    @IBAction func didSlide(_ sender: UISlider) {
        print("🛤", #function, #line, "Slider value:", Int(sender.value))
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?){
        if motion == .motionShake {
            slider.isHidden.toggle()
        }
    }
}
