
import Foundation
import KikDomain

// Only the newGame function is exported from the implementation
// all other functions come from the results of the previous move.
public struct KikAPI {
    public let newGame: MoveCapability
}

public let kikAPI: KikAPI =
    KikAPI(
        newGame: KikImplementation.newGame
    )
