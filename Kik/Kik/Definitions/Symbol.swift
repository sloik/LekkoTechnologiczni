
enum Symbol: String, CaseIterable {
    case X    = "X"
    case O    = "O"
    case none = "-"
}

extension Symbol {
    var isNone: Bool {
         Symbol.none == self
    }

    var oposite: Symbol {
        switch self {
        case    .X: return .O
        case    .O: return .X
        case .none: return .none
        }
    }
}
