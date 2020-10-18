
// Inspiration: https://www.pointfree.co/episodes/ep1-functions

import Foundation

public typealias SideEffect = Void

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


// MARK - Bind

precedencegroup MonadicComputation{
    associativity: left
}

infix operator >>= : MonadicComputation

public func >>=<T, U>(a: T?, f: (T) -> U?) -> U? {
  return a.flatMap(f)
}

public func >>=<T, U>(a: [T], f: (T) -> U?) -> [U] {
    return a.compactMap(f)
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
    higherThan: MonadicComputation
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

public func <^> <A, B>(
    _ a: A,
    _ f: @escaping (A) -> B
    )
    -> B {
        return map(a, f)
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
