
import Foundation
import Either
import Prelude
import OptionalAPI

// MARK: - PUBLIC
public typealias GridViewButtonHandler = (ButtonIndex) -> Void
public typealias GridViewTitleProducer = (ButtonIndex) -> String

public enum GridViewModel {
    case gridVisible(action: GridViewButtonHandler, title: GridViewTitleProducer)
}


// MARK: - Internal

extension GridViewModel {
    var action: GridViewButtonHandler? {
        switch self {
        case .gridVisible(action: let action, title: _):
            return action
        }
        
        return .none
    }
    
    var title: GridViewTitleProducer? {
        switch self {
        case .gridVisible(action: _, title: let title):
            return title
        }
        
        return .none
    }
}

extension GridViewModel {
    func runAction(_ viewButtonIndex: Int) {
        
        switch self {
        case .gridVisible(action: let action, title: _):
            ButtonIndex(rawValue: viewButtonIndex)
                .andThen( action )
        }
        
       
    }
}
