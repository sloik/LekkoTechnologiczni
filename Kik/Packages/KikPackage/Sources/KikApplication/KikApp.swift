
import UIKit
import GridView
import KikImplementation
import Prelude
import KikDomain
import FunctionalAPI
import Overture

struct KikGameState {
    let gridViewController: GridViewController?
}

var State: KikGameState!


func toTitle(_ state: CellState) -> String {
    switch state {
    case .played(let player): return player |> toString
    case .empty:              return "▢"
    }
}

func toString(_ player: Player) -> String {
    switch player {
    case .x: return "🥒"
    case .o: return "🍅"
    }
}

func toGridViewModel(_ moveResult: MoveResult) -> GridViewModel {

    let buttonHandler: GridViewButtonHandler
    let titleProducer: (ButtonIndex) -> String

    switch moveResult {
    case .playerXMove(let displayInfo, let nextMoveInfo):
        buttonHandler = nextMoveInfo |> makeButtonHandler
        titleProducer = displayInfo |> toTitle

    case .playerOMove(let displayInfo, let nextMoveInfo):
        buttonHandler = nextMoveInfo |> makeButtonHandler
        titleProducer = displayInfo |> toTitle

    case .gameWon(let displayInfo, let player):
        buttonHandler = [] |> makeButtonHandler
        titleProducer = displayInfo |> toTitle

    case .gameTie(let displayInfo):
        buttonHandler = [] |> makeButtonHandler
        titleProducer = displayInfo |> toTitle
    }

    return .init(
        actionForButton: buttonHandler,
        titleForElement: titleProducer
    )
}


let buttonIndexMap: [ButtonIndex: CellPosition] = {

    /// To be inline with the GridView cell should be generated from top left
    /// (top,     left), (top,     hCenter), (top,     right),
    /// (vCenter, left), (vCenter, hCenter), (vCenter, right)
    /// ...
    let allPositions: [(VertPosition, HorizPosition)] = product(VertPosition.allCases, HorizPosition.allCases)

    precondition(
        allPositions.count == ButtonIndex.allCases.count,
        "Should have same number of positions as there are button in GridView!"
    )

    let indexesWithCoordinates: [(ButtonIndex, (VertPosition, HorizPosition))] = Array(zip(ButtonIndex.allCases, allPositions))

    return
        indexesWithCoordinates
        .map { (zipped: (ButtonIndex, (VertPosition, HorizPosition))) -> (ButtonIndex, CellPosition) in
            let (buttonIndex, cellCoordinates) = zipped

            /// `cellCoordinates` are generated in a way that they do not exactly fit to the init function.
            /// We can take care of this in a couple of ways:
            ///     1) when it's generated just swap the positions
            ///
            /// but then we will miss our super transforming powers and:
            ///     2) make CellPosition.init accept parameters in different order.
            ///
            /// In a `real app` #1 sounds way better but we are learning and we will
            /// go with #2 😎
            let cellPosition: CellPosition =
                CellPosition.init(hp:vp:)
                |>  Overture.curry >>> Overture.flip >>> Overture.uncurry
                // At this point we have something like this: CellPosition.init(vp:hp)
                // This is just the thing that we can put cell coordinates in to.
                <| cellCoordinates

            return (buttonIndex, cellPosition)}
        |> Dictionary.init(uniqueKeysWithValues:)
}()

func toCellPosition(_ buttonIndex: ButtonIndex) -> CellPosition {
    buttonIndexMap[buttonIndex]!
}

func toTitle(_ displayInfo: DisplayInfo) -> (ButtonIndex) -> String {
    { (buttonIndex: ButtonIndex) in
        displayInfo
            .cells
            .first(where:
                    ^\Cell.pos >>> ( (==) |> Overture.curry <| buttonIndex |> toCellPosition )
            )!
            |> ^\Cell.state >>> toTitle

        /// 😲 what the hell is going on in here?!?! You probably are asking yourself.
        /// tl;dr is that:
        /// "take the first cell where pos is equal to button index and change if to title"
        ///
        /// yeah... but how? let's break it apart from the top
        /// `cells` is a array of `Cell`, easy :)
        ///
        /// `first` is a higher order function that expects a predicate. This predicate
        /// is just a fancy way of saying _function that takes something and returns Bool_.
        /// But because cells has type `[Cell]` then that means that this predicate will
        /// have to take as input instance of a `Cell` and return a `Bool`.
        ///
        /// So we need to check if that cell has the same position as the cell for that index.
        ///
        /// `^\Cell.pos`
        /// this will create a function that returns just the position `(Cell) -> CellPosition`.
        /// Simple getter for a property but made out of KeyPath.
        ///
        /// `>>>`
        /// This just combines functions. So we have `(Cell) -> CellPosition`on the left. To
        /// make a `(Cell) -> Bool` predicate we need a `(CellPosition) -> Bool` function.
        /// That way when combined it will give the desired type.
        ///
        /// Ok so now we know what we need on the right side.
        ///
        /// To compare instances in Swift we use a `==` operator. This is just a generic function
        /// that when specialised to our use case will have a type:
        /// `(CellPosition, CellPosition) -> Bool`
        ///
        /// What we would like to have is a comparator function that will ALWAYS compare to a fixed
        /// position and "wait" for the other one to check if they match.
        ///
        /// `buttonIndex |> toCellPosition`
        /// This just translates button index (world of GridView) to cell position (world of Kik Domain).
        /// So that's the fixed position. We could write this code like so:
        ///
        /// ```
        ///     let positionToMatchOn: CellPosition) = buttonIndex |> toCellPosition
        ///     ...
        ///     ^\Cell.pos >>> ( (==) |> Overture.curry <| positionToMatchOn )
        /// ```
        ///
        /// I agree it's less cryptic and normally that's the way to go. But again we are learning 🤓
        /// Ok so now we will speed up and aggregate everything together:
        ///
        /// `(==) |> Overture.curry`
        /// This just creates a curried version of `==` operator: `(CellPosition) -> (CellPosition) -> Bool`.
        ///
        /// `(==) |> Overture.curry <| buttonIndex |> toCellPosition`
        /// Now we are baking in the "fix position" as one of the arguments.Because operators
        /// have their precedence everything works. But it might be clearer if now I will add some:
        ///
        /// ```
        ///  ( (==) |> Overture.curry ) <| ( buttonIndex |> toCellPosition )
        /// ```
        /// Left side creates a curried version of `==` and right side gets `CellPosition`.
        /// After applying it by the use of `<|` operator this has a type:
        /// `(CellPosition) -> Bool`
        ///
        /// That is exactly what is needed on the right side of `>>>` operator!
        ///
        /// Again in all of it's glory:
        /// ```
        /// ^\Cell.pos >>> ( (==) |> Overture.curry <| buttonIndex |> toCellPosition )
        /// ```
        ///
        /// I know it might be hard to unpack this line. And you should avoid this kind
        /// of contraptions. Here we are bending our minds to flex them as a muscles on a gym.
        /// In real life go for the helper variables. Hey you can rewrite this piece of code
        /// to make it more readable 🤓
        ///
    }
}

func makeButtonHandler(_ moveInfo: [NextMoveInfo]) -> (ButtonIndex) -> Void {
    { (tapedButton: ButtonIndex) in
        moveInfo
            .first(where:
                ^\NextMoveInfo.posToPlay >>> { pos in pos == (tapedButton |> toCellPosition) }
            )
            .andThen(
                ^\NextMoveInfo.capability
                >>> { (move: MoveCapability) -> MoveResult in move() }
                >>> updateGridView
            )
            ?? ()
    }
}

func updateGridView(_ moveResult: MoveResult) {
    State
        .gridViewController
        .map(GridViewController.bind)
        .map{ (bind: (GridViewModel) -> Void) in
            bind <| moveResult |> toGridViewModel
        }
}
