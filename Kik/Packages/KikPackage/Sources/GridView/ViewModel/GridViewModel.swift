
import Foundation
import Either
import Prelude
import OptionalAPI

// MARK: - PUBLIC
public typealias GridViewButtonHandler = (ButtonIndex) -> Void
public struct GridViewModel {
    let actionForButton: GridViewButtonHandler
    let titleForElement: (ButtonIndex) -> String

    public init(
        actionForButton: @escaping GridViewButtonHandler,
        titleForElement: @escaping (ButtonIndex) -> String) {
        self.actionForButton = actionForButton
        self.titleForElement = titleForElement
    }
}


// MARK: - Internal

extension GridViewModel {
    func runAction(_ viewButtonIndex: Int) {
        ButtonIndex(rawValue: viewButtonIndex)
            .andThen( actionForButton )
    }
}
