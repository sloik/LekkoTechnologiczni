
import Foundation

public typealias ButtonAction = () -> Void

public var nop: ButtonAction { {} }

func run(_ action: ButtonAction) {
    action()
}
