import UIKit
import GridView
import KikImplementation
import Prelude
import KikDomain
import FunctionalAPI
import Overture

public var startApp: UIViewController {
    kikAPI.newGame()
        |> toGridViewModel
        |> gridViewController
        |> KikGameState.init(gridViewController:)
        |> { (state: KikGameState) in State = state }
        |> { State.gridViewController! }
}
