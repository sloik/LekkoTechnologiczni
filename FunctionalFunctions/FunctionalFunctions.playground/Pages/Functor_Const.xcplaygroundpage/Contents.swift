//: [Previous](@previous)

import Foundation

/*:
 
 * [Documentation Haskell Data.Functor.Const](https://hackage.haskell.org/package/base-4.14.1.0/docs/Data-Functor-Const.html)
 * [Code](https://hackage.haskell.org/package/base-4.14.1.0/docs/src/Data.Functor.Const.html#Const)
 
 ```haskell
 -- | The 'Const' functor.
 newtype Const a b = Const { getConst :: a }
 ```
 */

struct Const<A, TypeWitness> { // Type Witness -> Phantom Type
    let getConst: A
}

extension Const {
    func map<NewWitness>(_ : @escaping (TypeWitness) -> NewWitness) -> Const<A, NewWitness> { .init(getConst: self.getConst) }
}

protocol WitnessA {}

run("🩳 const") {
    let const = Const<Int, WitnessA>(getConst: 42)
    let mapped = const.map{ print("🦄", $0) }
    print( mapped.getConst )
    print( type(of: mapped) )
}

/*:
 `Const` abstrahuje wartość, której nie możemy zmienić. Nie dość, że nie jest mutowalna to nigdy jej nie zmienimy w kodzie!
 
 Powiedzmy, że mamy potrzebujemy w aplikacji powiedzieć, że coś jest bezpieczne. Użyjemy do tego protokołu, który posłuży jedynie jako _świadek_ witness, że coś jest bezpieczne.
 
 > W zależności od tego jakie blogi czytasz to możliwe, że spotkałaś/eś się z określeniami _phantom type_, lub _marker protocol_. Różnice są delikatne ale z grubsza chodzi o to samo.
 */

protocol Secure {}

/*:
 Cokolwiek oznaczone tym protokołem mówi, że _jest bezpieczne_ (cokolwiek znaczy bezpieczne w kontekście domeny aplikacji a nie jakaś prawda absolutna!).
 
 Często chcemy aby hasło było bezpieczne. Więc potrzebujemy jakiejś fabryki, sposobu na tworzenie instancji _bezpiecznych haseł_. Co istotne w aplikacji powinno być tylko jedno takie miejsce. Co więcej nie ma potrzeby wymyślania nie wiadomo czego gdy **zwykła funkcja w zupełności wystarczy**.
 */

func secureTextFactory(_ value: String) -> Either<[String], Const<String, Secure>> {
    guard
        value.count >= 10 // fancy logic
    else { return .left(["Password to short!"]) }

    return .right( .init(getConst: value) )
}

/*:
 Fabryka zwróci listę błędów lub stałe bezpieczne hasło!
 */

run("👮‍♂️ factory") {
    print(
        secureTextFactory("to short").leftValue!,
        secureTextFactory("now this is way more secure!").rightValue!,
        
        separator: "\n"
    )
}

/*:
 W dalszej części kodu wystarczy, że metody będą przyjmowały instancje const:
 */

func safePrintPassword(_ pass: Const<String, Secure> ) -> SideEffect {
    let prefix = pass.getConst[..<pass.getConst.index(pass.getConst.startIndex, offsetBy: 3)]
    let suffix = pass
        .getConst[pass.getConst.index(pass.getConst.startIndex, offsetBy: 3)...]
        .map{ _ in "*" }
        .joined()

    print(#function, prefix + suffix)
}

run("🖨 secure print") {
    let securePassword = secureTextFactory("now this is way more secure!")
    
    securePassword
        .map( safePrintPassword )
}

/*:
 Mamy tu kilka fajnych rzeczy.
 
 Wartość, której nie możemy zmienić. Jedyny sposób aby do niej się dostać to użycie funkcji `map` a ona ignoruje tą funkcje! Phantom Type, który sprawia, że kompilator patrzy na ręce.
 
 Dzięki takiemu podejściu możemy napisać mniej testów a dalej mieć pewność, że kod działa! Oczywiście dalej trzeba przetestować samą implementacje funkcji map (ktoś może się pomylić przy jej pisaniu). Sprawdzić logikę fabryki, ale w samym kodzie już mamy _świadka_, że dana wartość się nie zmieni i jest bezpieczna!
 */



//: [Next](@next)
