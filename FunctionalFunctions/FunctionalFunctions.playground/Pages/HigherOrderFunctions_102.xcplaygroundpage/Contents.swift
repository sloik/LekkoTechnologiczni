/*:
 # First Order Function
 Dowiedzieliśmy się czym są funkcje. Teraz zajmiemy się tematami jak: **First Class Functions** oraz **Higher Order Functions**

 **First Class Functions** oznacza, że funkje mogą być przechowywane jako properties/zmienne,  przekazywane jako argumenty do funkcji lub metod oraz być typem zwracanym.

 Traktujemy je jak wartości/obiekty. O ile termin **Higher Order Functions** tyczy się matematycznych jak i programistycznych zagadnień to **First Class Functions** jest pojęciem typowo programistycznym. Dzięki **FCF** odblokowujemy jakoby **HOF** poprzez możliwość przekazania funkcji jak zwykły obiekt do innej funkcji.
 */

let intToString: (Int) -> (String) = { value in
    String(value)
}
type(of: intToString)

let convertedValue = intToString(10)
type(of: convertedValue)

/*:
 # Higher Order Function
 **Higher Order Functions** są to funckje, które spełniają przynajmniej jeden z konceptów:

 - Jako argument przyjmują funkcje
 - Zwracają funkcje

 W **Swift** mamy elementy ze świata funkcyjnego takei jak np: **Map, FlatMap, CompactMap, Filter i Reduce**.
 Jest to podejście typowo deklaratywne, skupiamy się na tym co chcemy zrobić, a nie w jaki sposób.
 Rozwiązuje nam to problem z **Dependency Inversion** poprzez przesunięcie zależności i opakowanie jej w warstwe abstrakcji.
 */
/*:
 # Map

 Najbardziej rozpoznawalnym ze świata **HOF** w **Swift** jest mapa. Tworzy kontener, nakłada ona naszą funkcje na kazdy element z podanej struktury i dodaje rezultat do kontenera, a po wykonaniu wszystkich obliczeń zwraca nam owy kontener z nowymi wartościami. Nasza stara struktura zostaje nienaruszona. Zdefiniowana jest np. dla takich typów jak: **Arrays, Dictionaries, Sets i Optional**. Działanie **Map** pokażemy na przykładzie **Array**.
 */

/*:
 # *Może warto wspomnieć:
 Mapa dla Set i Dictionary zwraca inny typ w sensie tablice a nie Set/Dictionary. Owszczem istnieje ale z perspektywy takiej matematycznej mapy / Funktora to nie jest prawilna mapa ;). (Rozwinięcie tematu w kolejnych odcinkach)
 */

/*:
 # Map
 Przykład implementacji mapy dla typu **Array**:
 */
// func map<T>(_ transform: (Element) -> T) -> [T] {
//    var returnContainerItems: [T] = []
//    for item in self {
//        returnContainerItems.append(transform(item))
//    }
//    return returnContainerItems
// }

let mapValues: [Int] = [1, 2, 3, 4, 5]
let incrementedValues: [Int] =
    mapValues
        .map { value in value + 1 }

/*:
 Zamiast implementować logike "wewnątrz" mapy, możemy do niej wstrzyknąć naszą wcześniej już zdefinowaną funkcje.
 */

func incrByTwo(_ value: Int) -> Int {
    return value + 2
}

let mapedValues = mapValues.map { value in incrByTwo(value) }
mapedValues

/*:
 Lub
 */

mapValues
    .map(incrByTwo)


/*:
 Poprzez takie podejście pozbywamy się boilerplate-a wynikającego z tworzenia kontenera na nowe wartości, pętli itp.. Wszystkie te rzeczy wykonuje za nas mapa, a my jedynie mówimy co chcemy aby się zadziało z przyjętym elementem z podanej struktury. Logika, która jest powtarzalna zostaje zamknięta w jednym obrębie tak aby była reużywalna i spójna. Kod staje się prostrzy, czytelny i łatwiejszy w utrzymaniu.

Jako, że optional jest kontenerem na wartość, możemy używać mapy na wartościach typu Optional. Jeśli chcielibyśmy przemnożyć wartość optionalną o 2 to tradycyjnym sposobem zastosowalibyśmy nil coalescing czyli nadanie defaultowej wartości w przypadku natrafienia na nil, a potem przemnożyli naszą wartość zmiennej przez 2.
*/

/*:
 Mapy możemy używać do chainowania pewnych operacji. Można to rozumieć, kiedy skończy się jedna operacja to na jej wyniku wykonaj kolejną operacje. W znanych konceptach jak **Promise** i **Future**, tak naprawdę dzieje się coś takiego, tylko że **under the hood** . Myśląc o wczesnej optymalizacji powinniśmy zrobić tyle w jednym obszarze mapy na ile pozwala nam na to semantyka i logika wykonanego zadania.
 */

let someIntOptional: Int? = 69
let someStringOptional = someIntOptional
    .map { $0 + 1 }
    .map (String.init)  // point free - bez odwoływania się do użytych danych
    .map { $0 + "test" }
    .map { $0.uppercased() }

/*:
 Dzięki mapie możemy zrobić to w czytelny i prostrzy sposób, mówiąc że chcemy wziąć wartość ze zmiennej typu optionalnego, przemnożyć ją przez 2, a na końcu wstawić tę wartość do typu optional. W przypadku braku wartości odpakujemy z optionala nil, a nastepnie znowu go zapakujemy w typ optionalny
 */

/// enum Optional<Wrapped> {
///   case none
///   case some(Wrapped)
/// }

extension Optional {
    func myMap<Transformed>(_ transform: (Wrapped) -> Transformed) -> Transformed? {
        switch self {
        case .none:
            return nil

        case .some(let wrapped):
            return .some(transform(wrapped))
        }
    }
}

assertEqual(
    Int?(69)
        .myMap { $0 + 1 }
        .myMap (String.init)
        .myMap { $0 + "test" }
        .myMap { $0.uppercased() },
    Int?(69)
        .map { $0 + 1 }
        .map (String.init)
        .map { $0 + "test" }
        .map { $0.uppercased() }
)


let optionalValue: Int? = 10
let newNilCoalescingValue: Int = (optionalValue ?? 10) * 2
let newMappedValeu =
    optionalValue
        .map { $0 * 2 }

type(of: newNilCoalescingValue)
type(of: newMappedValeu)

/*: CompactMap
 W momencie gdy nie interesuje nas nic poza wartościami, używamy compactMap. CompactMap robi dokładnie to samo co map-a ale na samym końcu odpakowuje optionala i pozbywa się wartości jest ona nil-em. W poprzednich werjach **Swift** mieliśmy 3 zastosowania **flatMap** jednak przez to, że jedno z nich nie pasowało do semantyki zgodnej z **Funktorem**.
 */

let compactMapValues = ["a", "b", nil, "c"]
let compactedValues = compactMapValues.compactMap{ $0 }

compactMapValues
compactedValues

type(of: compactMapValues)
type(of: compactedValues)

/*:
 Jeśli chcemy pozbyć się mało intuicyjnego znaku **$0** oznaczającego nasz aktualny item, możemy użyć funkcji **id**.
 Jest to nic innego jak funkcja, która przyjmuje siebie i zwraca siebie. Semantyka zostaje zachowana przy poprawie czytelności,
 */
public func identity<A>(_ a: A) -> A { return a }

compactMapValues
    .compactMap(identity)

/*:
 Co w momencie gdy mamy zagnieżdżone w sobie kolekcje? Wtedy na ratunek przybywa flatMap.
 Transformuje dokładnie jak map, a na końcu "spłaszcza o jeden poziom" nasz wynik.
 */

let flatMapValues: [[Int]] = [[1, 2, 3], [4, 5, 6]]
let flattenMapValues = flatMapValues.flatMap { $0 }

flatMapValues
flattenMapValues

type(of: flatMapValues)
type(of: flattenMapValues)

/*:
Oczywiście można tą mapę zaimplementować troszeczkę prościej. Jednak zależy nam na tym aby pokazać jak ten cały proces wygląda krok po kroku.
*/
extension Optional {
    func myFlatMap<Transformed>(_ transform: (Wrapped) -> Transformed?) -> Transformed? {
        switch self {
        case .none:
            return nil

        case .some(let wrapped):                 // "odpakowanie"
            let transformed = transform(wrapped) // "transformacja"
            switch transformed {
            case .none:
                return nil

            case .some(let someTransformed):
                return .some(someTransformed)    // "zapakowanie"
            }
        }
    }
}

func maybyIncrement(_ i: Int) -> Int? { i + 1 }

type(of: Int?(42).map    (maybyIncrement)) // Int??
type(of: Int?(42).flatMap(maybyIncrement)) // Int?

assertEqual(
    Int?(42)
        .map(maybyIncrement)?
        .flatMap(identity),
    Int?(42)
        .map(maybyIncrement)?
        .myFlatMap(identity)
)

/*:
 # Filter
 Filtrowanie danych umożliwia nam funkcja filter. **Filtr** przechodzi przez każdy element wywołując na nim naszą funkcje.
 Jeśli wartunek zwróci true, element zostanie dodany do nowo utworzonego kontenera.
 */
let filterValues: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
let filteredValues = filterValues.filter { value in
    value > 3
}

filterValues
filteredValues

/*:
 Za pomocą filtru możemy również uzyskać działanie **compactMap**.
 */

let filterValuesWithNil: [Int?] = [1, 2, nil, 4, 5]
let filteredValuesWithoutNil = filterValuesWithNil
    .filter { $0 != nil }

filterValuesWithNil
filteredValuesWithoutNil



/*:
 # Reduce
 Ostatnią pomocną funkcja będzie reduce. Dzięki niej jesteśmy w stanie zliczyć wszystkie elementy sekwencji w zmienną typu prostego.
 */

let reduceValues: [Int] = [1, 2, 3, 4, 5, 6]
let reducedValue: Int = reduceValues.reduce(0, +)

reducedValue

/*:
 Możemy nawet zastosować reduce do otrzymania wartości typu **Bool**
 */

let reducedBool: Bool = reduceValues.reduce(true) {
    $0 && $1 < 7
}

reducedBool

/*:
 W momencie gdy chcemy otrzymać wynik w momencie natrafienia na nietrafiony warunek, używamy funkcji **allSatisfy**
 */
let satisfiedValue: Bool = reduceValues.allSatisfy { $0 < 7 }
satisfiedValue


/*:
 # Kompozycja
 Dzięki działaniu HOF świetnie to współgra z kompozycją.
 Załóżmy, że na wejściu mamy podaną cyfre i chcemy wykonać na niej wiele obliczeń.
 Zamiast tworzyć dodatkowe pomocniczne zmienne trzymające nasz tymczasowy wynik lub zagnieżdżać funkcje możemy chainować nasze operacje.
 */

let chainValues: [Int?] = [1, 2, nil, 4, 5]
let chainedValues: Int =
    chainValues
        .compactMap{ $0 }
        .filter { $0 < 4}
        .reduce(0, +)

chainValues
chainedValues

/*:
 # Higher Higher Order Function :]?
 Każda z wyżej przedstawionych funkcji ma swoją konkretną rolę i powód do użycia.
 A co gdyby za pomocą logiki jednej z funkcji i zmiany tylko konkretnych parametrów zmimikować działanie innych funkcji?
 Zaimplementujmy kazdą z wymienionych wyżej funkcji za pomocą jednej z nich: **Reduce**
 */



assertEqual(
    [1,2,3,4,5].map{ $0 + 1 },

    [1,2,3,4,5]
        .reduce([]) { (partialResult, value) in
            partialResult + [ value + 1 ]
        }
)

assertEqual(
    [1,2,nil,3,4,nil,5].compactMap(identity),

    [1,2,nil,3,4,nil,5]
        .reduce([]) { (partialResult, value) in
            switch value {
            case .none:
                return partialResult
            case .some(let wrapped):
                return partialResult + [ wrapped ]
            }
        }
)

assertEqual(
    [[1],[],[10, 20]].flatMap(identity),

    [[1],[],[10, 20]]
        .reduce([]) { (partialResult, value) in
            partialResult + value
        }
)

assertEqual(
    filterValues.filter { value in value > 3 },

    filterValues
        .reduce([]) { (partialResult, value) in
            value > 3
                ? partialResult + [value]
                : partialResult
    }
)

assertEqual(
     reduceValues.allSatisfy { $0 < 7 },

     reduceValues
         .reduce(true) { (partialResult, value) in
             partialResult && value < 7
     }
)

assertEqual(
     [].allSatisfy { $0 < 7 },

     [].reduce(true) { (partialResult, value) in
             partialResult && value < 7
     }
)

assertEqual(
    [1,2,3,4,5].first{ $0 > 2 },

    [1,2,3,4,5]
        .reduce(nil) { (partialResult, value) in
            guard partialResult == nil else { return partialResult }

            return
                value > 2
                    ? value
                    : nil
    }
)

/*:
 Niestety typ `Optional` nie ma zdefiniowanej funkcji `reduce`. Jak byśmy mogli ją zaimmplementować?
 */

func reduce<O, Q>(_ initial: O?,
                  _ query: (O) -> Q) -> Q? {

    switch initial {
    case .none:
        return nil

    case .some(let wrapedInitial):
        return query(wrapedInitial)
    }
}

let isGraterThan4 = { (i: Int) in i > 4 }
let increment     = { (i: Int) in i + 1 }

reduce(5, isGraterThan4)
reduce(4, isGraterThan4)
reduce(3, isGraterThan4)

reduce(5, increment)
reduce(4, increment)
reduce(3, increment)

type(of: reduce(4, maybyIncrement))

/*:
Ten _kształt_ wygląda bardzo znajomy.
*/

func mapOptional<O, T>(_ optional: O?,
                       _ transform: (O) -> T) -> T? {
    reduce(optional, transform)
}

assertEqual(Int?(5).map(isGraterThan4), reduce(5, isGraterThan4))
assertEqual(Int?(4).map(isGraterThan4), reduce(4, isGraterThan4))
assertEqual(Int?(3).map(isGraterThan4), reduce(3, isGraterThan4))

assertEqual(Int?(5).map(increment), reduce(5, increment))
assertEqual(Int?(4).map(increment), reduce(4, increment))
assertEqual(Int?(3).map(increment), reduce(3, increment))


