
import Foundation
import Prelude

extension Array where Element == ButtonAction {

    subscript(index: ButtonIndex) -> ButtonAction {
        self[ index |> toIntIndex ]
    }
    
}
