extension Optional {
    var isSome: Bool {
        switch self {
        case .none:    return false
        case .some(_): return true
        }
    }

    var isNone: Bool { !self.isSome }
}
