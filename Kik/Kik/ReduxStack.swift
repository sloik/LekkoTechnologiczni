
import ReSwift

let MainStore = Store<KikState>(
    reducer: mainReducer,
    state: nil,
    middleware: [
        logActionsMiddleware,
        gameMiddleware]
)

// MARK: - State

enum ViewState {
    case show(winner: String, grid: String)
    case showTie(grid: String)
    case showBoard
}

struct KikState: StateType {
    let game: KikModel
    let viewState: ViewState
}

// MARK: - Reducer

func mainReducer(_ action: Action, _ state: KikState?) -> KikState {
    let state = state ?? KikState(
        game: KikModel(currentSymbol: .O, model: Array(repeating: .none, count: 9)),
        viewState: .showBoard
    )
    
    if let kikAction = action as? StateActions {
        return stateActionsReducer(kikAction, state)
    }
    
    return state
}

func stateActionsReducer(_ action: StateActions, _ state: KikState) -> KikState {
    switch action {
    case .setState(let model, let viewState):
        return KikState(
            game: model,
            viewState: viewState
        )
    }
}

// MARK: - Action

enum UserActions: Action {
    case didTap(Int)
    case resetGame
}

enum StateActions: Action {
    case setState(KikModel, ViewState)
}

// MARK: - Middleware


//public typealias DispatchFunction = (Action) -> Void
//
//public typealias Middleware<State> =
//    (@escaping DispatchFunction, @escaping () -> State?) -> (@escaping DispatchFunction) -> DispatchFunction

let logActionsMiddleware: Middleware<KikState> =
{ dispatch, getState in    // (@escaping DispatchFunction, @escaping () -> State?)
    
    return { next in       // (@escaping DispatchFunction)
        
        return { action in // DispatchFunction => (Action) -> Void
            print("🎬 Action:", action)
            
            print("🍏", getState() as Any)
            next(action)
            print("🍎", getState() as Any)

        }
    }
}


let gameMiddleware: Middleware<KikState> =
{ dispatch, getState in    // (@escaping DispatchFunction, @escaping () -> State?)
    
    return { next in       // (@escaping DispatchFunction)
        
        return { action in // DispatchFunction => (Action) -> Void
        
            guard
                let kikAction = action as? UserActions, // akcja jest przeznaczona dla tego
                let state = getState()
                else {
                    next(action)
                    return
            }
            
            var copy = state.game
            
            switch kikAction {
            case .didTap(let index):
                let result = copy.didTapElement(index)
                
                switch result {
                case .winner:
                    dispatch(
                        StateActions
                            .setState(
                                copy,
                                .show(
                                    winner: copy.currentSymbol.rawValue,
                                    grid: gridFrom(copy)
                                )
                        )
                    )
                    
                case .tie:

                    
                    dispatch(
                        StateActions.setState(copy, .showTie(grid: gridFrom(copy)))
                    )
                    
                case .playing:
                    dispatch(
                        StateActions.setState(copy, .showBoard)
                    )
                }
                
                
            case .resetGame:
                copy.resetGame()
                
                dispatch(
                    StateActions.setState(copy, .showBoard)
                )
            }
            
            
//            next(action) // może być inny middleware zainteresowany tą akcją, jeżeli chcemy możemy ją tu "połknąć" nie wołając funckji next
        }
        
    }
    
}


let gridFrom: (KikModel) -> String = { model in
    model
        .grid
        .map(model.lineToSymbols(_:)) // .X, .O, .none
        .map{ symbols in
            symbols
                .map { $0.rawValue }      // "X", "O", "-"
                .joined(separator: " ") } // "X O -"
        .joined(separator: "\n")
}

