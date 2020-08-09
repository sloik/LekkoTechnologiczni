import UIKit
import Prelude
import OptionalAPI

public func gridViewController(_ viewModel: GridViewModel) -> GridViewController {
    UIStoryboard(name: "Grid", bundle: .module)
        .instantiateInitialViewController()
        .cast(GridViewController.self)
        .chain { gridVC in gridVC.bind <| viewModel }
        .andThen(id)!
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
            refreshAlert()
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
                let customTitle: String? = viewModel?.cellTitle <*> buttonIndex

                button
                    .setTitle(
                        customTitle.or( "\(button.tag)" ),
                        for: .normal
                    )
            }
    }
    
    func refreshAlert() {
        hideAllert()
        
        showAlert(title:message:actionTitle:action:)
            <*> viewModel?.alertVisible
    }

    func showAlert(
        title: String,
        message: String,
        actionTitle: String,
        action: @escaping AlertAction
    ) {
        let ok = UIAlertAction(title: actionTitle,
                               style: UIAlertAction.Style.default)
        { _ in action() }

        let alert = UIAlertController(title: title ,
                          message: message,
                          preferredStyle: .alert)

        alert.addAction(ok)

        present(alert, animated: true, completion: nil)
    }
    
    func hideAllert() {
        presentedViewController?.dismiss(animated: true, completion: .none)
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
