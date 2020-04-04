
import ReSwift

let MainStore = Store<KikState>(
    reducer: mainReducer,
    state: nil,
    middleware: [
        logActionsMiddleware,
        userActionsMiddleware,
        gameMiddleware,
        historyMiddleware,
    ]
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
