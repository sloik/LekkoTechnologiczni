
import ReSwift

/*:
 # Middleware
 
 Dają szansę na wywołanie dodatkowej logiki do obsłużenia akcji zanim trafią do reducera. Same w sobie są po prostu funkcjami wyższego rzędu.
 
 Mogą "połykać" akcje (np. akcja wywołująca strzał sieciowy) jak również wysyłać wiele innych akcji (np. pod jedną akcją może się kryć więcej akcji do wywołania).
 
 W `ReSwift` są zaimplementowane jako type aliasy:
 
 
 Zwykła funkcja konsumująca akcje:
 ```
 public typealias DispatchFunction = (Action) -> Void
 ```
 
 
 Funkcja wyższego rzędu. Na _pierwszyn_ poziomie dostaniemy referencje do funkcji pozwalającej wysłać akcje. Dzięki czemu nie musimy posiadać referencji do głównego _sklepu_. Oraz funkcję do pobrania aktualnego stanu.
 
 Na _drugim_ poziomie mamy referencje do funkcji przekazującej akcje do następnego middleware-a. Jeżeli nie ma żadnego to akcja wpada do reducera. Dzięki temu możemy wywołać logikę przed i/lub po obsłużeniu akcji. Jeżeli nie wywołamy tej funkcji to "połkniemy" aktualnie procesowaną akcje.
 
 _Trzeci_ poziom to jest ta część gdzie mamy dostęp do wszystkich tych argumentów.
 
 ```
 public typealias Middleware<State> =
     (@escaping DispatchFunction, @escaping () -> State?)
        -> (@escaping DispatchFunction)
        -> DispatchFunction
 ```
 
 */



// MARK: - Log
let logActionsMiddleware: Middleware<KikState> =
{ dispatch, getState in    // (@escaping DispatchFunction, @escaping () -> State?)
    
    return { next in       // (@escaping DispatchFunction)
        
        return { action in // DispatchFunction => (Action) -> Void
            let uuid = UUID()
            print("🍏", uuid,"action:", action,"| state:", getState()?.game.model as Any)
            next(action)
            print("🍎", uuid,"action:", action,"| state:", getState()?.game.model as Any)
        }
    }
}


// MARK: - Game Logic
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
            
            var newState = state.game
            
            switch kikAction {
            case .didTap(let index):
                let result = newState.didTapElement(index)
                
                switch result {
                case .winner:
                    dispatch(
                        StateActions
                            .setState(
                                newState,
                                .show(
                                    winner: newState.currentSymbol.rawValue,
                                    grid: gridFrom(newState)
                                )
                        )
                    )
                    
                case .tie:
                    dispatch(
                        StateActions.setState(newState, .showTie(grid: gridFrom(newState)))
                    )
                    
                case .playing:
                    dispatch(
                        StateActions.setState(newState, .showBoard)
                    )
                }
                
                
            case .resetGame:
                newState.resetGame()
                
                dispatch(
                    StateActions.setState(newState, .showBoard)
                )
            }
            
            
//            next(action) // może być inny middleware zainteresowany tą akcją, jeżeli chcemy możemy ją tu "połknąć" nie wołając funkcji next
        }
        
    }
    
}

// MARK: - User Actions
let userActionsMiddleware: Middleware<KikState> =
{ dispatch, getState in    // (@escaping DispatchFunction, @escaping () -> State?)
    
    return { next in       // (@escaping DispatchFunction)
        
        return { action in // DispatchFunction => (Action) -> Void
            guard
                action is UserActions
                else { next(action)
                    return }

            
            next(action)

            // Można to zrobić tak, że `HistoryMiddleware` sam zapisuje stan, ale
            // to jest przykład tego jak jeden MW wywołuje akcje dla innego MW.
            // I tak można zrobić z tego spagetti, ale ze wszystkiego można ;)
            getState()
                .map({ state in
                    dispatch(HistoryActions.save(state: state))
                })
        }
    }
}
