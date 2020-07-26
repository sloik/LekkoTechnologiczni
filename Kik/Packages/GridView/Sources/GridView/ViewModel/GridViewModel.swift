
import Foundation
import Either
import Prelude

// MARK: - PUBLIC

public struct GridViewModel {
    let actions: GridActions
    let titleForElement: (ButtonIndex) -> String
}

// MARK: - PUBLIC
// MARK: -- Functions
public func gridViewModel(
    _ elements: ButtonAction...,
    titleProducer: @escaping (ButtonIndex) -> String
) -> Either<ErrorMessage, GridViewModel> {
    gridViewModel(elements, titleProducer)
}

public func gridViewModel(
    _ elements: [ButtonAction],
    _ titleProducer: @escaping (ButtonIndex) -> String
) -> Either<ErrorMessage, GridViewModel> {
    guard
        elements.count == 9
    else {
        return .left("Invalid number of elements! Got: \(elements.count) but expected 9")
    }

    return
        .right(
            GridViewModel(
                actions: GridActions(
                    action0: elements[ .bi0 ],
                    action1: elements[ .bi1 ],
                    action2: elements[ .bi2 ],
                    action3: elements[ .bi3 ],
                    action4: elements[ .bi4 ],
                    action5: elements[ .bi5 ],
                    action6: elements[ .bi6 ],
                    action7: elements[ .bi7 ],
                    action8: elements[ .bi8 ]
                ),
                titleForElement: titleProducer
            )
        )
}

// MARK: - Internal

extension GridViewModel {
    func runAction(_ buttonIndex: Int) {
        
    }
}
