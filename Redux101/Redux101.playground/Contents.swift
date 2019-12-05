import UIKit

import ReSwift

NSSetUncaughtExceptionHandler{print("💥 Exception thrown: \($0)")}

/*:
# State

Modelowy obiek, który przetrzymuje najprostrze wartości związane z aplikacją. Jeżeli jest `Equatable` to ReSwift informuje subkrybenta tylko jezeli cos się zmieniło. W przeciwnym wypadku robi to za każdym razem.
*/

struct State: StateType, Equatable {
    let counter: Int
}

extension State {
    static var initial: State { State(counter: 0) }
}


/*:
# Action

Akcja może nam mówić o wszystkim. Użytkownik coś tapną, ekran się pojawił, wrócił response z serwera.
*/

enum Actions: Action {
    case increment
    case decrement

    enum Custom: Action {
        case incr(by: UInt)
    }
}


/*:
# Reducer

Funkcja, która z akcji i obecnego stanu zwraca stan zaktualizowany w oparciu o akcje jaka została przesłana.
*/

func reduceActions(_ actions: Actions, _ state: State) -> State {
    switch actions {
    case .increment:
        return State(counter: state.counter + 1)
    case .decrement:
        return State(counter: state.counter - 1)
    }
}

func reduceCustom(_ actions: Actions.Custom, _ state: State) -> State {
    switch actions {
    case .incr(let by):
        return State(counter: state.counter + Int(by))
    }
}

func actionsReducer(_ action: Action, _ state: State) -> State {
    switch action {
    case let actions as Actions:
        return reduceActions(actions, state)

    case let custom as Actions.Custom:
        return reduceCustom(custom, state)

    default:
        return state
    }
}

func mainReducer(_ action: Action, _ state: State?) -> State {
    actionsReducer(action,
                   state ?? .initial)
}


/*:
# Store

Synchronizuje dostęp do stanu i służy do notyfikowania o akcjach.
*/

let PlayState = Store<State>(reducer: mainReducer,
                             state: nil,
                             middleware: [])


/*:
Zobaczmy to w akcji 🍞
 */

PlayState.state.counter

let incrementAction = Actions.increment

PlayState.state.counter


PlayState.dispatch(incrementAction)

PlayState.state.counter

PlayState.dispatch(incrementAction)
PlayState.dispatch(incrementAction)

PlayState.state.counter


struct EmptyAction: Action {}

PlayState.dispatch(EmptyAction())
PlayState.dispatch(EmptyAction())
PlayState.dispatch(EmptyAction())
PlayState.dispatch(EmptyAction())

PlayState.state.counter

PlayState.dispatch(Actions.Custom.incr(by: 42))

PlayState.state.counter

PlayState.dispatch(Actions.decrement)
PlayState.dispatch(Actions.decrement)
PlayState.dispatch(Actions.decrement)

PlayState.state.counter


/*:
W momencie gdy zmienia się stan wszyscy zarejestrowani subkrybenci zostają o tym poinformowani.
 */

class StoreSub: StoreSubscriber {

    func newState(state: State) {
        print(#function, "   \(state)")
    }

    init() {
        PlayState.subscribe(self)
    }

    func addFive() {
        PlayState
            .dispatch(Actions.Custom.incr(by: 5))
    }
}

let sub = StoreSub()

PlayState.dispatch(EmptyAction())
PlayState.dispatch(Actions.increment)
PlayState.dispatch(Actions.decrement)

sub.addFive()

PlayState.state.counter


















print("🤩🤩🤩")

























