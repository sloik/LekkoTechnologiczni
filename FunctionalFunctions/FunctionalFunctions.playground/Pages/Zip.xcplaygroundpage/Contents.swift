//: [Previous](@previous)

import Foundation

NSSetUncaughtExceptionHandler{ print("💥 Exception thrown: \($0)") }

/*:
# Zip 🤐
 
 Widzieliśmy, że Swift daje nam dwie funkcje, które są bardzo dobrze znane w świecie funkcyjnym _map_ i _flatMap_. Aby nieco je lepiej ze sobą skomponować musieliśmy sami napisać ich globalne wersje.
 
 Teraz rzucimy okiem na kolejną funkcję bardzo dobrze znaną w świecie funkcyjnym. Jest to funkcja o wdzięcznej nazwie **zip**. Co więcej już w samym Swift jest zdefiniowana globalnie!
 
 ```swift
 func zip<Sequence1, Sequence2>(
     _ sequence1: Sequence1,
     _ sequence2: Sequence2)
 
 -> Zip2Sequence<Sequence1, Sequence2> ...
 ```
 
 Ta definicja odpowiada 1:1 [definicji z Haskella](https://hoogle.haskell.org/?hoogle=zip) czyli:
 
 `zip<A,B>(_ a: [A], _ b: [B]) -> [(A, B)]`
 
 Popatrzmy jak ta funkcja działa:
*/

let fourNumbers    = [ 4 ,  3 ,  2 ,  1 ]
let fourCharacters = ["A", "B", "C", "D"]

run("👶🏻 first zip") {
    
    print(
        "numbers zip-ed with characters:",
        zip(fourNumbers, fourCharacters) |> Array.init
    )
    
    print(
        "index and character:",
        zip(fourCharacters.indices, fourCharacters) |> Array.init
    )
    
    print(
        "index and number:",
        zip(fourNumbers.indices, fourNumbers) |> Array.init
    )
    
    print(
        "End index:",
        fourNumbers.indices.endIndex
    )
    
    print(
        "Just enumerated:",
        fourNumbers.enumerated()
    )
    
    print(
        "Map-ed enumerated:",
        fourNumbers.enumerated().map(identity)
    )
}

/*:
 Za każdym razem niczym zamek błyskawiczny dostaliśmy parę odpowiadających sobie elementów. Co jednak gdy tablice nie mają takiej samej długości?
 */

let threeNumbers = [ 3 ,  2 ,  1 ]
let threeChars   = ["a", "b", "c"]

run("⚖️ unbalanced zip") {
    print(
        zip(threeNumbers, fourCharacters) |> Array.init
    )
    
    print(
        zip(fourCharacters, threeChars) |> Array.init
    )
}

/*:
 Wygląda na to, że _zip_ wie ile elementów może ze sobą zzipować. Zobaczmy do czego jeszcze można to wykorzystać:
 */

run("🍛 chars") {
    print(
        "Last N elements with index:",
        zip(
            fourCharacters.suffix(2)        ,
            fourCharacters.suffix(2).indices
            )
            |> Array.init // (element, index)
    )
    
    print(
        "Last N but using enumerated:",
        fourCharacters
            .suffix(2)
            .enumerated()
            .map(identity)
    )
}

/*:
 W pierwszym wypadku dostaliśmy bardzo fajnie zzipowane elementy oraz index _w oryginalnej tablicy_. Natomiast korzystając z enumerated indexy były _lokalne_ i nie odpowiadały pozycji w _oryginalnej tablicy_. Robi to sens ponieważ enumerated jest wołany na instancji ArraySlice i to jego indeksy widać.
 
 Wykorzystując właściwość, że zip _zna_ długości tablic i wie kiedy skończyć możemy wykorzystać do generowania krotek.
 */

run("🗞 Generator") {
    print(
        "Pairs of next to each other elements:",
        zip(
            fourCharacters,
            fourCharacters.dropFirst()
        )
        |> Array.init
    )
    
    print(
        "Pairs of every 2nd element:",
        zip(
            fourCharacters,
            fourCharacters.dropFirst(2)
        )
        |> Array.init
    )
    
    print(
        "Pairs of every 3rd element:",
        zip(
            fourCharacters,
            fourCharacters.dropFirst(3)
        )
        |> Array.init
    )
    
    print(
        "Custom indexes:",
        zip(
            10...,      // "nieskończona" sekwencja!
            fourCharacters
        )
        |> Array.init
    )
}

/*:
 Jak wcześniej napiszmy własną implementację aby nabrać intuicji co się dzieje pod spodem :)
 */

func myZip<A,B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
    var result:  [(A, B)] = []
    
    (0 ..< min(xs.count, ys.count))
        .forEach { index in result.append( ( xs[index], ys[index] ) ) }
    
    return result
}

/*:
 Swift daje nam tylko Zip na 2 kolekcjach. Jak można zdefiniować funkcję zip dla więlszej ilości argumentów? W Haskellu możemy doszukać się nawet definicji [zip7](https://hoogle.haskell.org/?hoogle=zip7 ). My się zatrzymamy na 4 ;)
 */

func zip<A,B,C>(_ xs:[A], _ ys: [B], _ zs: [C]) -> [(A,B,C)] {
    myZip( myZip(xs, ys), zs )
        .map { xy, z in (xy.0, xy.1, z) }
}

func zip<A,B,C,D>(_ xs:[A], _ ys: [B], _ zs: [C], _ qs: [D]) -> [(A,B,C,D)] {
    myZip(zip(xs, ys, zs), qs)
        .map{ xyz, q in (xyz.0, xyz.1, xyz.2, q) }
}

/*:
 Jak widać proces jest bardzo mechaniczny i można użyc jakiegoś generatora kodu do tego lub skorzystać z [już napisanego kodu](https://github.com/pointfreeco/swift-overture/blob/f61b98879b/Sources/Overture/ZipSequence.swift ). Jak dobrze poszukacie w repozytorium to okaże się, że są tam już napisane funkcje `zip` do innych typów :)
 
 Patrząc na typy tych funkcji otrzymamy coś takiego:
 ```
 ([A], [B])           -> [(A, B)]
 ([A], [B], [C])      -> [(A, B, C)]
 ([A], [B], [C], [D]) -> [(A, B, C, D)]
 ```
 
 Widać, że funkcja `zip` wywraca na durugą stronę kontenery. Czyli z `([])` krotki tablic otrzymaliśmy `[()]` tablice krotek. W tym momencie to może jeszcze się nie wydaje praktyczne ale dobre rzeczy przychodzą do tych co czekają ;)
 
 ## [zipWith](https://hoogle.haskell.org/?hoogle=zipWith)
 
 W Haskellu jest jeszcze warjacja na temat funkcji zip. Konkretnie jej wersja ([zipWith](https://hoogle.haskell.org/?hoogle=zipWith)), która przyjmuje funkcje jako argument. Zadaniem tej funkcji jest powiedzenie w jaki sposób mają być przetransformowane zip-powane te wartości. Domyślnie zip zip-uje do krotek.
 */

func zip<A,B,C>(with f: @escaping (A,B) -> C)
    -> ([A], [B]) -> [C] {
        return { xs, ys in
            zip(xs, ys).map(f)
        }
}

func zip<A,B,C,D>(with f: @escaping (A,B,C) -> D)
    -> ([A], [B], [C]) -> [D] {
        return { xs, ys, zs in
            zip(xs, ys, zs).map(f)
        }
}

/*:
 Dzięki temu możemy mapować funkcje, które przyjmują większą ilość argumentów! Funkcja _map_ zawsze miała jeden element, teraz mamy ich więcej.
 */

let    nums = [1, 2, 3, 4]
let bigNums = [100, 200, 300, 400]
let wowNums = [1_000, 2_000, 3_000, 4_000]

run("🦠 zip with") {
    print(
        (nums, bigNums) |> zip(with: +)
    )
    
    print(
        (nums, bigNums, wowNums)
            |> zip(with: { arg1, arg2, arg3 in arg1 + arg2 + arg3 } )
    )
}

/*:
 Zobaczmy jakiś przykład blizszy życiu ;)
 */

enum Mood {
    case ok
    case meh
}

struct Person: CustomDebugStringConvertible {
    let name: String
    let age: Int
    
    var debugDescription: String { "<Person: \(name) has \(age) years>" }
}

let names = ["Dżesika", "Patrycja", "Brajanusz"]
let  ages = [29, 32, 19]
let moods = [Mood.ok, .meh, .ok]

struct MoodyPerson: CustomDebugStringConvertible {
    let name: String
    let age: Int
    let mood: Mood
    
    var debugDescription: String { "<MP: \(name) has \(age) years is in \(mood) mood>" }
}

run("🖇 Personal") {
    print(
        (names, ages)
            |> zip(with: Person.init(name:age:))
    )
    
    print(
        zip(names, ages).map(Person.init)
    )
    
    print(
        (names, ages, moods)
            |> zip(with: MoodyPerson.init(name:age:mood:))
    )
    
    print(
        zip(names, ages, moods).map(MoodyPerson.init(name:age:mood:))
    )
}

/*:
Coś takiego może się nam przydać jak dostajemy kilka wartości z _różnych miejsc_. Strzały sieciowe, pola w formularzu... często chcemy je zebrać do kupy i przetransformować do innej _wartości_. W naszym przypadku imie, wiek i nastrój połączyliśmy w kolekcje MoodyPerson-s.
 
 Jednak lształt tej funkcji nie do końca odpowiada temu z czym można się spotkać w _normalnej_ pracy. Wartości w polach formularza raczej nie są tablicami a konkretnymi wartościami... być może takimi, które w danym momencie nie są nawet wypełnione!
 
 # zip? zipWith?
 
 To co nas spotka w żuciu to raczej nie pewność czy coś jest czy może jednak nie ;) Zobaczmy jak wygląda `zip` na optionalu :)
 */

func zip<A,B>(_ a: A?, _ b: B?) -> (A, B)? {
    guard let a = a, let b = b else { return .none }
    return (a, b)
}

let trueName: String? = "Dżesika"
let noneName: String? = .none

let trueAge: Int? = 26
let noneAge: Int? = .none

run("🧪 zip maybe") {
    print(
        zip(trueName, trueAge).map(Person.init(name:age:)) as Any,
        "Rest is optional:",
        zip(noneName, trueAge).map(Person.init(name:age:)) as Any,
        zip(trueName, noneAge).map(Person.init(name:age:)) as Any,
        zip(noneName, noneAge).map(Person.init(name:age:)) as Any
    )
    __
    
    zip(trueName, trueAge)
        .map{ print(type(of: $0)) }
    
    zip(trueName, noneAge)
        .map{ _ in fatalError("Nigdy się nie wykona! Przynajmniej jedna wartość jest nil") }
}

/*:
 Bezpiecznie zebraliśmy 2 różne opcjonalne wartości i stworzyliśmy z nich instancję `Person`. Co bardzo ważne z zewnątrz to wygląda jak Optional (bo nim jest), ale _map_ pozwala nam działać wewnątrz na już nie opcjonalnych wartościach!
 
 Dla _kompletu_ zdefiniujmy jeszcze funkcje zip3 oraz zip with dla Optional-i :)
 */

func zip<A,B,C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
    zip( zip(a, b), c ).map { ab, c in (ab.0, ab.1, c) }
    
    // zip(a?, b?)      => (a, b)?
    // zip((a, b)?, c?) => (a, b, c)?
}


func zip<A,B,C>(with f: @escaping (A,B) -> C) -> (A?, B?) -> C? {
    return { (a, b) in
        zip(a,b).map(f)
    }
}

func zip<A,B,C,D>(with f: @escaping (A,B,C) -> D) -> (A?, B?, C?) -> D? {
    return { (a, b, c) in
        zip(a,b,c).map(f)
    }
}

let trueMood: Mood? = .meh
let noneMood: Mood? = .none

run("🔑 zip with maybe") {
    let names = [trueName, noneName]
    let ages  = [trueAge, noneAge]
    let moods = [trueMood, noneMood]
    
    product(names, ages, moods)                                                 // [(String?, Int?, Mood?)]
        <^> { (n,a,m) in print("For params:", (n, a, m)) ; return (n, a, m) }   // [(String?, Int?, Mood?)]
        <^> zip(with: MoodyPerson.init(name:age:mood:))                         // [MoodyPerson?]
        <^> { (person: MoodyPerson?) -> SideEffect in print(person as Any) }
    
    __
    
    product(names, ages, moods)
        <^> { (n,a,m) in print("For params:", (n, a, m)) ; return (n, a, m) }
            >>>  zip(with: MoodyPerson.init(name:age:mood:))
            >>> { (person: MoodyPerson?) -> SideEffect in print(person as Any) }
        
}


/*:
 
 ## Podsumowanie
 
 To nie jest wszysctko co można zrobić z mapą. W przyszłości zaprezentujemy inne typy i postaramy się na nich zaimplementować funkcję zip :)
 
 Zamykając jednak na ten moment temat funkcji `zip` widać że mamy jednorodny interface, który pozwala nam powiedzieć co to znaczy zebrać ileś wartości razem w jednym kontenerze i je opcjonalnie przetransformować :)
 
 */


//: [Next](@next)
