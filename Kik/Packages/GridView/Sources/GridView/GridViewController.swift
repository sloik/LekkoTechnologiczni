import UIKit

public func gridViewController(_ viewModel: GridViewModel) -> GridViewController {
    let storyboard = UIStoryboard(name: "Grid", bundle: .module)

    let gridVC = storyboard.instantiateInitialViewController() as! GridViewController

    return gridVC
}

public final class GridViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var slider: UISlider! {
        didSet {
            slider.isHidden = true
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        addAccessibilityIdentifiers()
    }

    @IBAction func didTapButton(_ sender: UIButton) {
        print("🛤", #function, #line)
    }
}

// MARK: - Public

public extension GridViewController {
    func bind(_ vm: GridViewModel) {
        
    }
}

// MARK: - Internal

extension GridViewController {
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

extension GridViewController {
    
    func addAccessibilityIdentifiers() {
        for button in buttons {
            button.isAccessibilityElement = true
            button.accessibilityIdentifier = String(button.tag)
        }
    }
}

// MARK: - Slider

extension GridViewController {
    @IBAction func didSlide(_ sender: UISlider) {
        print("🛤", #function, #line, "Slider value:", Int(sender.value))
    }
    
    public override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?){
        if motion == .motionShake {
            slider.isHidden.toggle()
        }
    }
}
