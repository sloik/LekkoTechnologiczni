//: [Previous](@previous)

import Foundation

/*:
# To lub tamto
 
 * To lub Nil => Optional;
 * To lub Error => Result (tylko Swift Result ma pomylone Left i Right)
 
https://hackage.haskell.org/package/base-4.12.0.0/docs/Data-Either.html
*/

typealias SideEffect = Void

typealias SideEffectClosure = () -> SideEffect

typealias HandlerClosure<T>  = (T) -> SideEffect
typealias ConsumerClosure<T> = HandlerClosure<T>

typealias ProducerClosure<T> = () -> T
typealias InitClosure<T> = ProducerClosure<T>

typealias Closure<In,Out> = (In) -> Out
typealias Closure2In<I,II,O> = (I, II) -> O

/*:
 # Either
 */

enum Either<Left, Right> {
    case left(Left)
    case right(Right)
}

extension Either {
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

run("🍊 Either map, right map, left map, bi map") {
    print(
        Either<Int, String>
            .right("42")
            .rightMap( Int.init ) // (String) -> Int?
            .rightMap{ $0 <^> { (i: Int) in i + 1 } }
        ,
        Either<Int, String>
            .left(42)
            .rightMap{ Int($0) }
            .rightMap{ $0 <^> { (i: Int) in i + 1 } }
        ,
        Either<Int, String>
            .left(42)
            .biMap( String.init , { Int($0)! })
            .rightMap { $0 + 1 }
            .leftMap{ $0 + "!" }
        ,
        Either<Int, String>
            .right("40")
            .biMap( String.init , { Int($0)! })
            .rightMap { $0 + 1 }
            .leftMap{ $0 + "!" }
        
        , separator: "\n")
}

/*:
 # Flat Map
 */

extension Either {
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

run("🗾 Either flatMap") {
    print(
        Either<String, String>
            .right("42")
            .rightFlatMap{ (Int($0) <^> Either<String, Int>.right) ?? .left("unable to create Int at line \(#line)!") }
            .rightMap{ (i: Int) in i + 10 }
            .leftMap { print("Ups: ", $0) }
    )
    
    // Wyprintowanie Errora
    Either<String, String>
        .right("🌵")
        .rightFlatMap{ (Int($0) <^> (Either<String, Int>.right)) ?? .left("unable to create Int at line \(#line)!") }
        .rightMap{ (i: Int) in i + 10 }
        .leftMap { print(">> Ups: ", $0) }
    
    
    // Domyslna wartosc
    Either<String, String>
        .right("🌵")
        .rightFlatMap{ (Int($0) <^> (Either<String, Int>.right)) ?? .left("unable to create Int at line \(#line)!") }
        // jeżeli coś poszło nie tak to zwrócimy .right(42)
        .leftFlatMap { _ in 42 |> Either<String, Int>.right }
        .rightMap{ (i: Int) in i + 10 }
        .rightMap{ print(">>>> Yey: ", $0) }
        .leftMap { print(">>>> Ups: ", $0) }
}

extension Either {
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
}

run("☀️ Either onError") {
    Either<String, String>
        .left("42")
        .rightFlatMap{ (Int($0) <^> (Either<String, Int>.right)) ?? .left("unable to create Int!") }
        .rightMap{ (i: Int) in i + 10 }
        .onError { _ in print(#line, ">> Ups, coś poszło nie tak :(") }
        .onError {      print(#line, ">>", $0) }

}

extension Either {
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

run("🍟 Either onSuccess") {
    Either<String, String>
        .right("42")
        .rightFlatMap({
            Int($0)
                <^> Either<String, Int>.right
                ?? .left("unable to create Int!") })
        .rightMap{ (i: Int) in i + 10 }
        .onSuccess{ print("Result of computation is", $0) }
}

extension Either {
    func recover(with recorevFuction: @autoclosure @escaping ProducerClosure<Right>) -> Either<Left, Right> {
        leftValue
            <^> { _ in recorevFuction() }
            <^> Either<Left, Right>.right
            ?? self
    }
    
    func recover(_ recorevFuction: @escaping Closure<Left,Right>) -> Either<Left, Right> {
        leftValue
            <^> recorevFuction
            <^> Either<Left, Right>.right
            ?? self
    }
}

run("🚑 Either recover") {
    Either<String, String>
        .right("🌵")
        .rightFlatMap({
            Int($0)
                <^> Either<String, Int>.right
                ?? .left("unable to create Int!") })
        .recover(with: 42)
        .rightMap{ (i: Int) in i + 10 }
        .onSuccess{ print("Result of computation", $0) }
        .onError { _ in print(#line, ">> Ups, coś poszło nie tak :(") }
        .onError {      print(#line, ">>", $0) }
    
    Either<String, String>
        .right("🌵")
        .rightFlatMap{
            Int($0)
                <^> Either<String, Int>.right
                ?? .left( Bool.random() ? "unable to create Int!" : "Some other thing") }
        .recover{ errMsg in errMsg.contains("unable")  ? 100 : 1000 }
        .rightMap{ (i: Int) in i + 10 }
        .onSuccess{ print(#line, "Result of computation", $0) }
        .onError  { print(#line, ">> Ups, coś poszło nie tak :(") }
        .onError  { print(#line, ">>", $0) }
}

extension Either {
    func recoverN(with recoverFunction: @autoclosure @escaping ProducerClosure<Right>) -> Either<Never, Right> {
        leftValue
            <^> { _ in recoverFunction() }
            <^> Either<Never, Right>.right
            ?? rightValue! |> Either<Never, Right>.right
    }
    
    func recoverN(_ recoverFunction: @escaping Closure<Left,Right>) -> Either<Never, Right> {
        leftValue
            <^> recoverFunction
            <^> Either<Never, Right>.right
            ?? rightValue! |> Either<Never, Right>.right
    }
}

run("💥 Either recoverN") {
    Either<String, String>
        .right("🌵")
        .rightFlatMap({
            Int($0)
                <^> Either<String, Int>.right
                ?? .left("unable to create Int!") })
        .recoverN(with: 42)
        .rightMap{ (i: Int) in i + 10 }
        .onSuccess{ print(#line, "⏲ Result of computation", $0) }
        .onError  { print(#line, "⏲ >> Ups, coś poszło nie tak :(") }
        .onError  { print(#line, "⏲ >>", $0) }
    
    Either<String, String>
        .right("🌵")
        .rightFlatMap({ (right: String) in
            Int(right)
                <^> Either<String, Int>.right
                ?? .left( Bool.random() ? "unable to create Int!" : "Some other thing")
        })
        .recoverN { errMsg in errMsg.contains("unable")  ? 100 : 1000 }
        .rightMap { (i: Int) in i + 10 }
        .onSuccess{ print("🎭 Result of computation", $0) }
        .onError  { print("🎭 >> Ups, coś poszło nie tak :(") }
        .onError  { print("🎭 >>", $0) }
        .rightValue
        <^> { (result: Int) in print(#line, "🎭 Result from right", result) }
}


/*:
 # Zip
 */

func zip<A,B,L>(_ a: Either<L, A>, _ b: Either<L, B>) -> Either<[L], (A,B)> {
    switch (a, b) {
    case (.right(let a), .right(let b)):
        return .right((a, b))
        
    case (.right, .left(let l)):
        return .left([l])
        
    case (.left(let l), .right):
        return .left([l])
        
    case (.left(let l1), .left(let l2)):
        return .left([l1, l2])
    }
}

func zip<A,B,C,D>(with f: @escaping Closure2In<A,B,C>) -> (Either<D,A>, Either<D,B>) -> Either<[D],C> {
    return { eda, ebd in zip(eda, ebd).map( f ) }
}

/*:
 Niestety dla przypadku z dwiema lewymi wartościami aby nie tracić informacji musimy owinąć je w tablice. Idealnie by było aby typ sam wiedział jak się łączyć ;)
 */

protocol SingleTypeCombinable {
    static func <>(_ l: Self, _ r: Self) -> Self
}

extension Int: SingleTypeCombinable {
    static func <> (l: Int, r: Int) -> Int { l + r }
}

/*:
 `Int` można jeszcze połączyć w inny sposób, za pomocą mnożenia. To jednak otwiera nam drogę do innego tematu, którym zajmiemy się w przyszłości. Chociaż, te przykłady co mamy teraz już dość mocno o ten temat zahaczają ;)
 */

extension String: SingleTypeCombinable {
    static func <> (l: String, r: String) -> String { l + "\n" + r }
}

extension Array: SingleTypeCombinable {
    static func <> (l: Array<Element>, r: Array<Element>) -> Array<Element> {
        l + r
    }
}


extension Optional where Wrapped: SingleTypeCombinable {
    static func <> (l: Wrapped?, r: Wrapped?) -> Wrapped? {
        zip(l, r) <^> (<>)
        
//            .map( <> )
        
//            .map({ (arg0) -> Wrapped in
//                let (lw, rw) = arg0
//                return lw <> rw
//            })
    }
}

run("🌀 operator <>") {
    print(
        1 <> 2,
        1 <> 2 <> 3,
        
        Int?(4)  <> Int?(4) as Any,
        Int?(40) <> Int?(2) as Any,
        Int?(4)  <> .none   as Any,
        
        "czy" <> "ta" <> "pani",
        
        String?("co za") <> String?("magia") as Any,
                
        separator: "\n---\n"
    )
}

/*:
 Mamy już jakąś intuicje jak działa operator `<>`. Czas zdefiniować `zip` który nie traci informacji!
 */

func zip<A,B,L: SingleTypeCombinable>(
    _ a: Either<L, A>,
    _ b: Either<L, B>)
    -> Either<L, (A, B)> {
        
    switch (a, b) {
    case (.right(let a), .right(let b)):
        return .right((a, b))
        
    case (.right, .left(let l)):
        return .left( l )
        
    case (.left(let l), .right):
        return .left( l )
        
    case (.left(let l1), .left(let l2)):
        return .left( l1 <> l2 )
    }
}

run("🧠 zip with either") {
    print(
        zip(
            Either<String, Int>.right(4),
            Either<String, Int>.right(10)
        ),
        
        zip(
            Either<String, Int>.right(4),
            Either<String, Int>.left("2nd was left")
        ),
        
        zip(
            Either<String, Int>.left("1st was left"),
            Either<String, Int>.right(10)
        ),
        
        zip(
            Either<String, Int>.left("1st was left"),
            Either<String, Int>.left("2nd was left")
        )
        , separator: "\n")
}

/*:
 # Codable
 */
extension Either: Codable where Left: Codable, Right: Codable {
    enum CodingKeys: CodingKey { case left, right }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            let l = try container.decode(Left.self, forKey: .left)
            self = .left( l )
        } catch {
            let r = try container.decode(Right.self, forKey: .right)
            self = .right( r )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {

        case .left(let value):
            try container.encode(value, forKey: .left)
        case .right(let value):
            try container.encode(value, forKey: .right)
        }
    }
}

run("🐤 encoded") {
    let left : Either<String, Int> = .left ("left-value")
    let right: Either<String, Int> = .right(42)
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    print( String(data: try! encoder.encode(left), encoding: .utf8)! )
    print( String(data: try! encoder.encode(right), encoding: .utf8)! )

}


/*:
 
 # Nice Things - Nicer API
 
 */

extension Either where Left == Right {
    
    var optional: Left? { rightValue ?? leftValue }
    
    var anyValue: Left {
        switch self {
        case .left(let l) : return l
        case .right(let r): return r
        }
    }
}

extension Either where Left: Error {
    var result: Result<Right, Left> {
        switch self {
        case .left(let value): return .failure(value)
        case .right(let value): return .success(value)
        }
    }
}

extension String: Error {}

run ("✨ this or that"){
    let left : Either<String, Int> = .left("left-value")
    let right: Either<String, Int> = .right(42)
    let same : Either<Int, Int> = .right(24)
    let sameL: Either<Int, Int> = .left(44)
   
print(
    "Is left  left : \(String(describing: left.leftValue))",
    "Is left  right: \(String(describing: left.rightValue))",
    "Is right left : \(String(describing: right.leftValue))",
    "Is right right: \(String(describing: right.rightValue))",
    "",
    "Same  optional: \(String(describing: same.optional))",
    "SameL optional: \(String(describing: sameL.optional))",
    "",
    "Left  result: \(left.result)",
    "Right result: \(right.result)",
    separator: "\n")
}

extension Array {
    func lefts<L ,R>() -> [L] where Element == Either<L,R> { compactMap(\.leftValue)  }
    func rights<L,R>() -> [R] where Element == Either<L,R> { compactMap(\.rightValue) }
}

/*:

 # Linki

* Testing Failure with Either Instead of Exceptions
  https://www.youtube.com/watch?v=6YInxGbSiCY
 
* Haskell for Imperative Programmers #22 - Either
  https://youtu.be/IgdZX5wav1Q
 */


print("🥳🥳🥳")
