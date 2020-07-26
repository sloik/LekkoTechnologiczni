
import Foundation
import Either
import Prelude

enum ButtonIndex: Int {
    case bi0
    case bi1
    case bi2
    case bi3
    case bi4
    case bi5
    case bi6
    case bi7
    case bi8
}

public struct GridViewModel {
    let actions: GridActions
}

public func gridViewModel(_ elements: ButtonAction...) -> Either<ErrorMessage, GridViewModel> {
    gridViewModel(elements)
}

public func gridViewModel(_ elements: [ButtonAction]) -> Either<ErrorMessage, GridViewModel> {
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
                )
            )
        )
}

func arrayIndex(_ buttonIndex: ButtonIndex) -> Int {
    buttonIndex.rawValue
}

extension Array where Element == ButtonAction {
    subscript(index: ButtonIndex) -> ButtonAction {
        self[index |> arrayIndex]
    }
}
