
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
    case alertVisible(
            title: String,
            message: String,
            actionTitle: String,
            alertAction: AlertAction,
            titleProducer: TitleProducer)
}


// MARK: - Internal

extension GridViewModel {
    var visibleAction: ButtonHandler? {
        switch self {
        case .gridVisible(action: let action, title: _): return action
        
        default: return .none
        }
    }
    
    var cellTitle: TitleProducer {
        switch self {
        case .gridVisible(action: _, title: let title):
            return title
            
        case .alertVisible(title: _, message: _, actionTitle: _, alertAction: _, titleProducer: let titleProducer):
            return titleProducer
        }
    }
    
    var alertVisible: (String, String, String, AlertAction)? {
        switch self {
        case .alertVisible(title: let title, message: let message, actionTitle: let actionTitle, alertAction: let alertAction, titleProducer: _):
            return (title, message, actionTitle, alertAction)
            
        default:
            return .none
        }
    }
}

extension GridViewModel {
    func runAction(_ viewButtonIndex: Int) {
        visibleAction
            <*> ButtonIndex(rawValue: viewButtonIndex)
    }
}
