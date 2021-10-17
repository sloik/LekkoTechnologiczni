//: [Previous](@previous)

import Foundation

/*:
 # Flat Map 🍽 🗾
 
 W części o funkcjach wyższego rzędu (_map_) wpominaliśmy, że czasem otrzymujemy zagnieżdżoną strukturę (akurat jeżeli mowa o strukturach, które są generyczne i mają zdefiniowaną funkcje map to zawsze dojdzie do takiej sytuacji). Tablicę wewnątrz tablicy... Optional wewnątrz Optional-a... Result w Result-cie... itd.
 
 Dziś zaczniemy się bliżej przyglądać funkcji, która pozwoliła nam pozbyć się tego zagnieżdżenia: **flatMap**. Na początek przypomnijmy sobie jak działa na typach które dostępne są już teraz w Swift:
 */

/// Given a value of `A` wraps it inside and `Array<A>`.
func wrapInArray<A>(_ a: A) -> [A] { [a] }

/// Given a value of `A` wraps it inside `Optional<A>`.
func wrapInOption<A>(_ a: A) -> A? { .some(a) }

/*:
 Obie funkcje po prostu _owijają_ wartość w jakiś _kontekst_.
 */

let numbers = [1,2,3,4]
let wrappedNumbers: [ [Int] ] = numbers.map( wrapInArray )

let number: Int? = 42
let wrappedOptionalNumber: Int?? = number.map( wrapInOption )

run("📟 what we work with...") {

    print("Type of wrapped array is   :", type(of: wrappedNumbers), wrappedNumbers)
    print("Type of wrapped optional is:", type(of: wrappedOptionalNumber), wrappedOptionalNumber as Any)
}

/*:
 Z prostej struktury dostajemy bardziej rozbudowaną. Niestety to sprawia, że gdy chcemy dobrać się do danych musimy przejść bardzo manualnie przez te warstwy.
 */
    
run("🌽 the problem") {
    func consumerOfWrappedArrays(_ arrays: [[Int]]) {
        for innerArray in arrays {
            for number in innerArray {
                print(number)
            }
        }
    }
    
    __
    consumerOfWrappedArrays( wrappedNumbers )
    __
    
    func consumerOfWrappedOptionalInt(_ optionalOptionalInt: Int??) {
        if let optionalInt = optionalOptionalInt {
            if let int = optionalInt {
                print(int)
            }
        }
    }
    
    consumerOfWrappedOptionalInt( wrappedOptionalNumber )
}

/*:
 
 W obu przypadkach dostaliśmy tą samą strukturę zawiniętą w tej samej strukturze. Optional w Optional-u, array w array-ju. Dodatkowo gdy chcemy dobrać się do wartości musimy tą strukturę odpakować w bardzo ręczny sposób. Owszem składnia Swift daje nam pewne skróty które sprawiają, że łatwiej jest wyciągnąć te wartości. Jednak trzeba przyznać, że przykład jest zabawkowy i w "prawdziwej" aplikacji takie rozwiązanie skaluje się nieco gorzej.
 
Jak musiałby wyglądać kod, który musi przebić się przez poniższe poziomy? Raczej nic pięknego ;)
 */

let _ : [[[[[Int]]]]] = numbers.map( wrapInArray ).map( wrapInArray ).map( wrapInArray ).map( wrapInArray )
let _ : Int?????      = number.map( wrapInOption ).map( wrapInOption ).map( wrapInOption ).map( wrapInOption )

/*:

 Na szczęście nie jesteśmy sami. May do dyspozycji _flatMap_
 */

let _ : [Int] = numbers.flatMap( wrapInArray ).flatMap( wrapInArray ).flatMap( wrapInArray ).flatMap( wrapInArray )
let _ : Int?  = number.flatMap( wrapInOption ).flatMap( wrapInOption ).flatMap( wrapInOption ).flatMap( wrapInOption )

/*:
 Dużo lepiej :D Ładna, płaska struktura z którą dużo łatwiej się pracuje.
 
 Wiadomo co teraz zrobimy. Robiliśmy to już przy odcinku z kompozycją. Napiszemy naszą implementacje dla Array i Optional.
 */

/// Alias for functions of type `A -> B`.
typealias Closure<In, Out> = (In) -> Out

extension Array {
    func myFlatMap<Transformed>(_ transform: Closure<Element, [Transformed]> ) -> [Transformed] {
        var accumulator: [Transformed] = []
        
        for element in self {
            accumulator += element |> transform
        }
        
        return accumulator
    }
}

extension Optional {
    func myFlatMap<Transformed>(_ transform: Closure<Wrapped, Transformed?> ) -> Transformed? {
        switch self {
        case .none:
            return .none
            
        case .some(let wrapped):
            return wrapped |> transform
        }
    }
}

assertEqual(
    [1,2,3].flatMap( wrapInArray ).flatMap( wrapInArray ).flatMap( wrapInArray ),
    [1,2,3].myFlatMap( wrapInArray ).myFlatMap( wrapInArray ).myFlatMap( wrapInArray )
)

assertEqual(
    Int?(42).flatMap( wrapInOption ).flatMap( wrapInOption ).flatMap( wrapInOption ),
    Int?(42).myFlatMap( wrapInOption ).myFlatMap( wrapInOption ).myFlatMap( wrapInOption )
)

/*:
 To co na pierwszy rzut oka widać i od czego zaczęliśmy to, że pozbywamy się jednego poziomu zagnieżdżenia. To co może umknąć to to, że przekazujemy wynik poprzedniej operacji (funkcji, obliczenia), która może zwrócić taką samą strukturę.
 
 Czyli jeżeli moja funkcja zwraca Optional to dalej przekazuje tylko _happy path_. Taki w którym coś w tym Optional-u było. I mój cały _pipeline_ leci dalej. Jak tylko coś pójdzie nie tak to zwracam `none`.
 
 # Wolność
 
 Ludzie, informacja i funkcje powinny być wolne ;) Zrobiliśmy to samo z mapą więc zrobimy to samo z _flatMap_ą :)
 */

/// Free function.
/// - Parameter f:Closure transforming `Element` in to `[Transformed]`.
/// - Returns: Function that takes as input array of `Element` and returns array of `Transformed`.
func flatMap<Transformed, Element>(
    _ f: @escaping Closure<Element, [Transformed]>
) -> Closure<[Element], [Transformed]> {
    return { es in es.myFlatMap(f) }
}

/// Free function.
/// - Parameter f:Closure transforming `Element` in to `[Transformed]`.
/// - Returns: Function that takes as input array of `Element` and returns array of `Transformed`.
func flatMap<Transformed, Wrapped>(
    _ f: @escaping Closure<Wrapped, Transformed?>
) -> Closure<Wrapped?, Transformed?> {
        return { wrapped in wrapped.myFlatMap(f)}
}

precedencegroup MonadicApplication {
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
    associativity: left
}

infix operator >>= : MonadicApplication

public func >>= <A, B>(
    _ a: [A],
    _ f: @escaping (A) -> [B]
    )
    -> [B] {
         a |> flatMap(f)
}

public func >>= <A, B>(
    _ a: A?,
    _ f: @escaping (A) -> B?
    )
    -> B? {
         a |> flatMap(f)
}

/*:
 Czy to nie przedziwne, że obie implementacje wyglądają identycznie? Weźmy nasz operator na szybką przejażdżkę ;)
 */

run("🎢 flat map") {
    assertEqual(
        [1,2,3].flatMap(wrapInArray).flatMap(wrapInArray).flatMap(wrapInArray),
        [1,2,3] >>= wrapInArray >>= wrapInArray >>= wrapInArray >>= wrapInArray
    )

    assertEqual(
        Int?(42).flatMap(wrapInOption).flatMap(wrapInOption).flatMap(wrapInOption),
        Int?(42) >>= wrapInOption >>= wrapInOption >>= wrapInOption >>= wrapInOption
    )
    
    func maybeIncrement(_ i: Int) -> Int? { i + 1 }
    
    print(
        Int?(42)
            <^> maybeIncrement
            <^> { (i: Int?) in print(#line, i as Any) }
    )
    
    print(
          Int?(42)
              >>= maybeIncrement
              >>= { (i: Int) -> Int in print("line:", #line, "value:", i); return i }
              >>> { (i: Int) -> Int in print("line:", #line, "value:", i); return i }
    )
}

/*:
 
 ## Podsumowanie
 
 Tak jak _map_ możemy napisać dla wielu innych typów, tak samo możemy napisać _flatMap_.
 
 Zanim przejdę całkiem do końca chciałbym abyśmy razem jeszcze rzucili okiem na typy tych funkcji:
 
 ```
 flatMap<Transformed, Element>(_ f: (Element) -> [Transformed]) -> ([Element]) -> [Transformed]
 
 flatMap: ((E) -> [T]) -> ([E]) -> [T]

 
 func flatMap<Transformed, Wrapped>(_ f: (Wrapped) -> Transformed?) -> (Wrapped?) -> Transformed?
 
 flatMap: ((W) -> T?) -> (W?) -> T?
  ```
 
 Jest tu pewien schemat, który do nas krzyczy. Możemy to zapisać bardziej ogólnie:
 
 ```
 flatMap: ( (W) -> M<T>) -> (M<W>) -> M<T>
 ```
 
 Aby nie uciekło nam najważniejsze. Bind, bo taką nazwę ma operator `>>=` flatMap, służy do **połączenia wyjścia jednej funkcji z wejściem drugiej**.
 
 Można też spojrzeć na to odrobinę inaczej. Kolejna funkcja zakłada, że poprzednia zakończyła się _sukcesem_.
 
 */



//: [Next](@next)
