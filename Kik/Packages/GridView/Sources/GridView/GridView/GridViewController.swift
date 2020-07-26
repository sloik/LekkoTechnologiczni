import UIKit
import Prelude
import OptionalAPI

public func gridViewController(_ viewModel: GridViewModel) -> GridViewController {
    let storyboard = UIStoryboard(name: "Grid", bundle: .module)

    let gridVC =
        storyboard
        .instantiateInitialViewController()
        .cast(GridViewController.self)!

    gridVC.bind <| viewModel

    return gridVC
}

public final class GridViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]?
    @IBOutlet weak var slider: UISlider! {
        didSet {
            slider.isHidden = true
        }
    }

    private(set) var viewModel: GridViewModel? {
        didSet {
            refreshTitles()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        refreshTitles()
        addAccessibilityIdentifiers()
    }

    @IBAction func didTapButton(_ sender: UIButton) {
        viewModel?.runAction <*> sender.tag
    }
}

// MARK: - Public

public extension GridViewController {
    func bind(_ vm: GridViewModel) {
        viewModel = vm
    }
}

// MARK: - Internal

extension GridViewController {
    func refreshTitles() {
        buttons?
            .forEach { (button: UIButton) in
                let buttonIndex: ButtonIndex? = button.tag |> ButtonIndex.init(rawValue:)
                let customTitle: String? = viewModel?.titleForElement <*> buttonIndex

                button.setTitle(
                    customTitle.or( "\(button.tag)" ),
                    for: .normal
                )
            }
    }

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
        buttons?
            .forEach{ (button: UIButton) in
                button.isAccessibilityElement = true
                button.accessibilityIdentifier = button.tag |> String.init
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
