
import Foundation

public struct GridActions {
    let action0: ButtonAction
    let action1: ButtonAction
    let action2: ButtonAction

    let action3: ButtonAction
    let action4: ButtonAction
    let action5: ButtonAction

    let action6: ButtonAction
    let action7: ButtonAction
    let action8: ButtonAction
}

extension GridActions {
    func actionFor(index: ButtonIndex) -> ButtonAction {
        switch index {
        case .bi0: return action0
        case .bi1: return action1
        case .bi2: return action2
        case .bi3: return action3
        case .bi4: return action4
        case .bi5: return action5
        case .bi6: return action6
        case .bi7: return action7
        case .bi8: return action8
        }
    }
}
