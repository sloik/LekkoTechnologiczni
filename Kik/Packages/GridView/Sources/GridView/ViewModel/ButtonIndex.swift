
import Foundation

public enum ButtonIndex: Int, CaseIterable {
    case bi0
    case bi1
    case bi2
    case bi3
    case bi4
    case bi5
    case bi6
    case bi7
    case bi8
}

public let toIntIndex: (ButtonIndex) -> Int = \ButtonIndex.rawValue
