
// Inspiration: https://www.pointfree.co/episodes/ep1-functions

import Foundation

public typealias SideEffect = Void
public typealias SideEffectClosure = () -> SideEffect
public typealias HandlerClosure<T>  = (T) -> SideEffect
public typealias ConsumerClosure<T> = HandlerClosure<T>
public typealias ProducerClosure<T> = () -> T
public typealias InitClosure<T> = ProducerClosure<T>
public typealias Closure<In,Out> = (In) -> Out
public typealias Closure2In<I,II,O> = (I, II) -> O

// MARK: - Functions

public func id      <A>(_ a: A) -> A { return a }
public func identity<A>(_ a: A) -> A { return a }


// MARK: - Prefix Operators

prefix operator ^
public prefix func ^<Root, Value>(_ kp: KeyPath<Root,Value>) -> (Root) -> Value {
    return { root in
        root[keyPath: kp]
    }
}


// MARK: - Pipe forward / Functional Composition

precedencegroup ForwardApplication {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator |>: ForwardApplication

public func |> <A, B>(x: A, f: (A) -> B) -> B {
    return f(x)
}

public func |> <A>(a: inout A, f: (inout A) -> Void) {
    f(&a)
}


// MARK: - Function Composition
precedencegroup ForwardComposition {
    higherThan: EffectfulComposition, FunctorialApplication
    associativity: right
}

infix operator >>>: ForwardComposition

public func >>> <A, B, C>(
    _ f: @escaping (A) -> B,
    _ g: @escaping (B) -> C)
    -> ((A) -> C) {
        return { a in a |> f |> g}
}

precedencegroup BackwardsComposition {
    associativity: left
}
infix operator <<<: BackwardsComposition
public func <<< <A,B,C>(
    _ f: @escaping (B) -> C,
    _ g: @escaping (A) -> B)
    -> (A) -> C {
        return { a in a |> g |> f }
}



// MARK: - Single Type Composytion
precedencegroup SingleTypeComposition {
    associativity: left
    higherThan: EffectfulComposition
}

infix operator <>: SingleTypeComposition

public func <> <A>(f: @escaping (A) -> A, g: @escaping (A) -> A) -> (A) -> A {
    return f >>> g
}

public func <> <A: AnyObject>(f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> (A) -> Void {
    return { a in
        f(a)
        g(a)
    }
}

public func <> <A>(f: @escaping (inout A) -> Void, g: @escaping (inout A) -> Void) -> (inout A) -> Void {
    return { a in
        f(&a)
        g(&a)
    }
}

// MARK: - Fish Operator

precedencegroup EffectfulComposition {
    associativity: left
    higherThan: ForwardApplication
}

// Fish 🐟 operator
infix operator >=>: EffectfulComposition

public func >=> <A,B,C>(
    _ f: @escaping (A) -> B?,
    _ g: @escaping (B) -> C?
    ) -> ((A) -> C?) {
    return { a in
        guard let b = a |> f else { return nil }
        return b |> g
    }
}

public func >=> <A,B,C>(
    _ f: @escaping (A) -> [B],
    _ g: @escaping (B) -> [C]
    ) -> ((A) -> [C]) {
    return { a in
        let bs = a |> f
        return bs.reduce(into: [C]()) { (accumulator, b) in
            accumulator.append(contentsOf: b |> g)
        }
    }
}

// MARK: - Functor

public func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
    return { aa in
        return aa.map(f)
    }
}

public func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
    return { a in
        return a.map(f)
    }
}

precedencegroup FunctorialApplication {
    associativity: left
    higherThan: NilCoalescingPrecedence
}

infix operator <^>: FunctorialApplication
public func <^> <A, B>(
    _ a: [A],
    _ f: @escaping (A) -> B
    )
    -> [B] {
        return a.map(f)
}

public func <^> <A, B>(
    _ a: A?,
    _ f: @escaping (A) -> B
    )
    -> B? {
        return a.map(f)
}

public func map<A,B>(_ a: A,
                     _ f: (A) -> B) -> B {
    return f(a)
}

// MARK: - Free Functions

#if canImport(UIKit)
import UIKit

public func viewController<T: UIViewController>(for searchType: T.Type,
                                                from fvc: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> T? {

    func search(in searchedVC: UIViewController) -> UIViewController? {
        switch searchedVC {
        case let navigationViewController as UINavigationController:
            for viewController in navigationViewController.viewControllers {
                if let found = search(in: viewController) {
                    return found
                }
            }

            return nil

        case let tabBarController as UITabBarController:
            guard let viewControllers = tabBarController.viewControllers else { return nil }

            for viewController in viewControllers {
                if let found = search(in: viewController) {
                    return found
                }
            }

            return nil

        default:
            for viewController in searchedVC.children {
                if let found = search(in: viewController) {
                    return found
                }
            }

            return type(of: searchedVC) == searchType ? searchedVC : nil
        }
    }

    return fvc
        .map(search(in:))
        .flatMap{ return $0 as? T }
}

#endif

// MARK: - Array Products

public func product<A, B>(_ aa: [A], _ bb: [B]) -> [(A, B)] {
    var accumulator: [(A, B)] = []
    aa.forEach{ a in
        bb.forEach{ b in
            accumulator.append((a, b))
        }
    }
    return accumulator
}

public func product<A, B, C>(_ aa: [A], _ bb: [B], _ cc: [C]) -> [(A, B, C)] {
    var accumulator: [(A, B, C)] = []

    product(aa, bb).forEach { (a, b) in
        cc.forEach{ c in
            accumulator.append((a, b, c))
        }

    }
    return accumulator
}

public func product<A, B, C, D>(_ aa: [A], _ bb: [B], _ cc: [C], _ dd: [D]) -> [(A, B, C, D)] {
    var accumulator: [(A, B, C, D)] = []

    product(aa, bb, cc).forEach { (a, b, c) in
        dd.forEach{ d in
            accumulator.append((a, b, c, d))
        }

    }
    return accumulator
}


// MARK: - Partial Application

public func partial<A, B, T>(_ f: @escaping (A, B) -> T, _ a: A) -> (B) -> T {
    return { b in f(a, b) }
}

public func partial<A, B, C, T>(_ f: @escaping (A, B, C) -> T, _ a: A) -> (B) -> (C) -> T {
    return { b in { c in f(a, b, c) } }
}


// MARK: -- Zip

public func zip<A, B>(
  _ a: A?,
  _ b: B?
) -> (A, B)? {
    guard let a = a, let b = b else {return nil}

    return (a,b)
}

public func zip<A, B, C>(
  _ a: A?,
  _ b: B?,
  _ c: C?
  ) -> (A, B, C)? {
  return zip(zip(a, b), c).map { ($0.0, $0.1, $1) }
}

public func zip<A, B, C, Z>(
  with transform: @escaping (A, B, C) -> Z,
  _ a: A?,
  _ b: B?,
  _ c: C?
  ) -> Z? {
  return zip(a, b, c).map(transform)
}

public func zip<A, B, C, D>(
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?
  ) -> (A, B, C, D)? {
  return zip(zip(a, b), c, d).map { ($0.0, $0.1, $1, $2) }
}

public func zip<A, B, C, D, Z>(
  with transform: @escaping (A, B, C, D) -> Z,
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?
  ) -> Z? {
  return zip(a, b, c, d).map(transform)
}

public func zip<A, B, C, D, E>(
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?,
  _ e: E?
  ) -> (A, B, C, D, E)? {
  return zip(zip(a, b), c, d, e).map { ($0.0, $0.1, $1, $2, $3) }
}

public func zip<A, B, C, D, E, Z>(
  with transform: @escaping (A, B, C, D, E) -> Z,
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?,
  _ e: E?
  ) -> Z? {
  return zip(a, b, c, d, e).map(transform)
}

public func zip<A, B, C, D, E, F>(
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?,
  _ e: E?,
  _ f: F?
  ) -> (A, B, C, D, E, F)? {
  return zip(zip(a, b), c, d, e, f).map { ($0.0, $0.1, $1, $2, $3, $4) }
}

public func zip<A, B, C, D, E, F, Z>(
  with transform: @escaping (A, B, C, D, E, F) -> Z,
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?,
  _ e: E?,
  _ f: F?
  ) -> Z? {
  return zip(a, b, c, d, e, f).map(transform)
}

public func zip<A, B, C, D, E, F, G>(
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?,
  _ e: E?,
  _ f: F?,
  _ g: G?
  ) -> (A, B, C, D, E, F, G)? {
  return zip(zip(a, b), c, d, e, f, g).map { ($0.0, $0.1, $1, $2, $3, $4, $5) }
}

public func zip<A, B, C, D, E, F, G, Z>(
  with transform: @escaping (A, B, C, D, E, F, G) -> Z,
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?,
  _ e: E?,
  _ f: F?,
  _ g: G?
  ) -> Z? {
  return zip(a, b, c, d, e, f, g).map(transform)
}

public func zip<A, B, C, D, E, F, G, H>(
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?,
  _ e: E?,
  _ f: F?,
  _ g: G?,
  _ h: H?
  ) -> (A, B, C, D, E, F, G, H)? {
  return zip(zip(a, b), c, d, e, f, g, h).map { ($0.0, $0.1, $1, $2, $3, $4, $5, $6) }
}

public func zip<A, B, C, D, E, F, G, H, Z>(
  with transform: @escaping (A, B, C, D, E, F, G, H) -> Z,
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?,
  _ e: E?,
  _ f: F?,
  _ g: G?,
  _ h: H?
  ) -> Z? {
  return zip(a, b, c, d, e, f, g, h).map(transform)
}

public func zip<A, B, C, D, E, F, G, H, I>(
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?,
  _ e: E?,
  _ f: F?,
  _ g: G?,
  _ h: H?,
  _ i: I?
  ) -> (A, B, C, D, E, F, G, H, I)? {
  return zip(zip(a, b), c, d, e, f, g, h, i).map { ($0.0, $0.1, $1, $2, $3, $4, $5, $6, $7) }
}

public func zip<A, B, C, D, E, F, G, H, I, Z>(
  with transform: @escaping (A, B, C, D, E, F, G, H, I) -> Z,
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?,
  _ e: E?,
  _ f: F?,
  _ g: G?,
  _ h: H?,
  _ i: I?
  ) -> Z? {
  return zip(a, b, c, d, e, f, g, h, i).map(transform)
}

public func zip<A, B, C, D, E, F, G, H, I, J>(
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?,
  _ e: E?,
  _ f: F?,
  _ g: G?,
  _ h: H?,
  _ i: I?,
  _ j: J?
  ) -> (A, B, C, D, E, F, G, H, I, J)? {
  return zip(zip(a, b), c, d, e, f, g, h, i, j).map { ($0.0, $0.1, $1, $2, $3, $4, $5, $6, $7, $8) }
}

public func zip<A, B, C, D, E, F, G, H, I, J, Z>(
  with transform: @escaping (A, B, C, D, E, F, G, H, I, J) -> Z,
  _ a: A?,
  _ b: B?,
  _ c: C?,
  _ d: D?,
  _ e: E?,
  _ f: F?,
  _ g: G?,
  _ h: H?,
  _ i: I?,
  _ j: J?
  ) -> Z? {
  return zip(a, b, c, d, e, f, g, h, i, j).map(transform)
}

/*:
 # Either
 */

public enum Either<Left, Right> {
    case left(Left)
    case right(Right)
}

public extension Either {
    var isRight: Bool {
        switch self {
        case .right: return true
        default: return false
        }
    }
    
    var isLeft: Bool {
        switch self {
        case .left: return true
        default: return false
        }
    }
    
    func map<T>(_ transform: (Right) -> T) -> Either<Left,T> {
        switch self {
        case .right(let r):
            return .right( transform( r ) )
            
        case .left(let l):
            return .left( l )
        }
    }
    
    func rightMap<R>(_ transform: (Right) -> R) -> Either<Left, R> {
        map(transform)
    }
    
    func leftMap<L>(_ transform: (Left) -> L) -> Either<L, Right> {
        switch self {
        case .right(let r):
            return .right( r )
            
        case .left(let l):
            return  .left( l |> transform )
        }
    }
    
    func biMap<L,R>( _  leftTransform:  (Left) -> L,
                     _ rightTransform: (Right) -> R)
        -> Either<L, R> {
            switch self {
            case .left (let l): return l |>  leftTransform |> Either<L, R>.left
            case .right(let r): return r |> rightTransform |> Either<L, R>.right
            }
    }
}

public extension Either {
    func flatMap<R>(_ transform: (Right) -> Either<Left, R> ) -> Either<Left, R> {
        switch self {
        case .left(let l) : return l |> Either<Left, R>.left
        case .right(let r): return r |> transform
        }
    }
    
    func rightFlatMap<R>(_ transform: (Right) -> Either<Left, R>) -> Either<Left, R> {
        flatMap(transform)
    }
    
    func leftFlatMap<L>(_ transform: (Left) -> Either<L, Right>) -> Either<L, Right> {
        switch self {
        case .left(let l) : return l |> transform
        case .right(let r): return r |> Either<L, Right>.right
        }
    }
    
}

public extension Either {
    var leftValue: Left? {
        switch self {
        case .left(let l): return l
        default          : return .none
        }
    }
    
    @discardableResult
    func onError(_ errorHandler: @escaping HandlerClosure<Left>) -> Either<Left, Right> {
        errorHandler |> leftMap // leftMap( errorHandler )
        return self
    }
    
    @discardableResult
    func onError(_ errorHandler: @escaping SideEffectClosure) -> Either<Left, Right> {
        if isLeft {
            errorHandler()
        }
        return self
    
    }
    
    var rightValue: Right? {
        switch self {
        case .right(let r): return r
        default           : return .none
        }
    }
    
    @discardableResult
    func onSuccess(_ successHandler: @escaping HandlerClosure<Right>) -> Either<Left, Right> {
        successHandler |> rightMap
        return self
    }
}
