
import Foundation
import Either
import Prelude
import OptionalAPI

// MARK: - PUBLIC
public typealias ButtonHandler = (ButtonIndex) -> Void
public typealias TitleProducer = (ButtonIndex) -> String
public typealias AlertAction   = () -> Void

public enum GridViewModel {
    case gridVisible(action: ButtonHandler, title: TitleProducer)
    case alertVisible(title: String, alertAction: AlertAction)
}


// MARK: - Internal

extension GridViewModel {
    var visibleAction: ButtonHandler? {
        switch self {
        case .gridVisible(action: let action, title: _): return action
        
        default: return .none
        }
    }
    
    var visibleTitle: TitleProducer? {
        switch self {
        case .gridVisible(action: _, title: let title): return title
            
        default: return .none
        }
    }
}

extension GridViewModel {
    func runAction(_ viewButtonIndex: Int) {
        visibleAction
            <*> ButtonIndex(rawValue: viewButtonIndex)
    }
}
