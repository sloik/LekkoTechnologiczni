
import ReSwift

enum HistoryActions: Action {
    case save(state: KikState)
    case restore(index: Int)
}

fileprivate var historyRepository: [KikState] = []

let historyMiddleware: Middleware<KikState> =
{ dispatch, getState in    // (@escaping DispatchFunction, @escaping () -> State?)
    
    return { next in       // (@escaping DispatchFunction)
        
        return { action in // DispatchFunction => (Action) -> Void
            
            guard
                let hAction = action as? HistoryActions
            else {
                next(action)
                return
            }
            
            switch hAction {
            case .save(let state):
                historyRepository.append(state)
                historyRepository = historyRepository.suffix(10)
                    
                
            case .restore(let index):
                guard
                    historyRepository.indices.contains(index)
                    else { return }
                
                let state = historyRepository[index]
                dispatch(
                    StateActions
                        .setState(state.game,
                                  state.viewState)
                )

            }
        }
    }
}

