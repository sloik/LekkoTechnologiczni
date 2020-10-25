//: [Previous](@previous)

import Foundation

NSSetUncaughtExceptionHandler{print("💥 Exception thrown: \($0)")}

/*:
 # Algebraiczne Typy Danych
 
 **Typ** - Zbiór wartości. Np. `Typ Int` zawiera wartości `-2,-1,0, 1,2,3...`. `Typ String` zawiera np. wartości: `a`, `aa`, `aaa`, `pies`, `Sasin wydał na nielegalne wybory 70 milionów i wszyscy mogą mu na pędzel skoczyć`.
 
 Aby nie było tak łatwo to pisząc program nie tworzymy instancji danego typu. Tak na prawdę piszemy text. Ten następnie jest zamieniany na wywołanie funkcji tworzącej instancje danego typu.
 
 Mając taką perspektywę można powiedzieć, że _typ to enumeracja wszystkich initializerów_.
 
 */

run {
    -1
    0
    1
}

/*:
 **Algebra** (Arabic al-jabr ‘the reunion of broken parts’, ‘bone-setting’, from jabara ‘reunite, restore’) - Określa symbole i zbiór zasad manipulowania nimi. Np. `a (b + 1) = ab + a`.
 
Są tu obecne symbole dla _zmiennych_ oraz dla _wartości_ oraz **symbole dla operacji** na tych wartościach. Szkolna klasyka czyli dodawanie i mnożenie.
 
 W programowaniu mówiąc o typach można pracować ze strukturami, które _zachowują się_ jak illoczyn kartezjański (mnożenie, ang. product types). Oraz enumeracjami, które _zachowują się_ jak dodawanie (sum types).
 
## Domena
 
 Projektując program zaczynamy definiować struktury danych (koszyk, książka, faktura) oraz operacje na tych danych (dodaj przedmiot do koszyka, podaj stronę książki,  opłać fakturę). Z takim podejściem można szybko _zamodelować_ program a detalami zająć się później.
 
## Algebra Typów
 
 Policzmy ile dany typ może mieć różnych instancji. Lub wracając do czasów szkolnych policzymy _ile elementów (instancji) jest w zbiorze (typie)_ (moc zbioru).
 
### Void
 
Przewrotnie zaczniemy od _typu pustego_. Void z ang. pustka/próżnia sugeruje, że nie powinno być żadnej instancji. Jednak łatwo udowodnić, że to nie prawda:
*/

run("🛶 nothing in hand") {
    let instanceOfVoid: Void = ()
    print(instanceOfVoid)
}

/*:
 Pusta krotka jest instancją typu `Void`! Co więcej Void to tylko typealias na pustą krotkę! W praktyce okazuje się, że pustka wcale nie jest taka pusta a **posiada dokładnie 1 instancję**.
 
 Osobiście uważam, że w innych językach programowania ten typ ma znacznie lepszą (bliższą prawdy) nazwę `Unit`. Przecież można stworzyć jedną instancję (można więcej, ale każda jest identyczna). Przykładami takich języków są Haskell, F#, Scala.
 
 Czy istnieje _prawdziwie pusty_ typ? Taki, którego instancji nie można stworzyć?
 
 ### Never
 */
run("💎 no nay never") {
    print(
        type(of: fatalError)
    )
}

/*:
 Funkcja `fatalError` zwraca instancje typu `Never`. Jednak czy aby na pewno? Co się stanie w momencie gdy zostanie uruchomiona? Aplikacja się wyłoży! **Nigdy nie dostaniemy instancji typu `Never`**.
 
 Warto zauważyć, że to wcale nie przeszkadza w pisaniu funkcji, które np. oczekują takiej wartości:
 */

run("👩‍🍳 consume never always compiles") {

    func consumeNever(_ never: Never) { print(#function) }
    
    // how to run consumer of never?
}

/*:
 Problem z tą funkcją jest taki, że nigdy jej nie uruchomimy ponieważ nie dostarczymy instancji do jej parametru.
 
Czym jest `Never`?
 
 Może zaskakujące ale ten typ jest enumeracją pozbawioną casa! Do tego taki _trick_ jest często wykorzystywany właśnie do tego aby mieć jakieś metody statyczne na typie a nie można było utworzyć instancji tego typu!
 
 ### Bool
 
 Mamy zero (Never), mamy jeden (Void)... czy mamy dwa? Tak! W Swift typ `Bool` ma dwoje _mieszkańców_ `true` oraz `false`.
 
 ### Dodawanie
 
 Często o enumeracjach mówi się (ang.) _sum types_. Zobaczmy dlaczego modelując _pory dnia_.
 
 Zaczniemy bardzo naiwnie i powiemy, że są 2 pory dnia. Możemy mięć _dzień_ lub _noc_. Po za _kreatywnymi_ przypadkami powiedzmy, że to jest prawda. Używając enumeracji zamodeluję to tak:
 */

run("🌇 naive time of day") {
    enum TimeOfDay: CaseIterable {
        case day
        case night
    }
    
    print(
        TimeOfDay.allCases.count
    )
}

/*:
 Licząc wszystkie możliwe instancję tego typu jakie mogę utworzyć otrzymam liczbę: 2. Gdy dodam kolejną porę dnia:
 */

run("🔦 little less naive time of day") {
    enum TimeOfDay: CaseIterable {
        case morning
        case day
        case night
    }
    
    print(
        TimeOfDay.allCases.count
    )
}

/*:
 Łatwo zauważyć, że **liczba możliwych instancji jest równa liczbie `case`ów**. Dodam jeden case to liczba wszystkich w sumie wzrasta o 1: ilość_obecnych + 1.

### Mnożenie
  
 _Product type_em_ w Swift są wszelkiego rodzaju struktury, klasy oraz krotki.
 
 Czas na kilka przykładów oraz policzenie ile możliwych kombinacji można wypisać.
 
 */

let _: (Bool, Bool) = (true , true )    // 1
let _: (Bool, Bool) = (true , false)    // 2
let _: (Bool, Bool) = (false, true )    // 3
let _: (Bool, Bool) = (false, false)    // 4

/*:
 Jeżeli w miejsce typu wpiszę jego _moc_ (liczbę możliwych instancji) to otrzymam krotkę, która wygląda tak:
 
 ```
 (2, 2)
 ```
 
 Widać, że ilość możliwych do stworzenia instancji dla takiego typu to 4, czyli 2 * 2.
 
 Może jednak to tylko przypadek? A może nie... rzućmy okiem na takie krotki:
 
 ```
 (2,2,1) => 2 * 2 * 1 = 4
 (2,1,2) => 2 * 1 * 2 = 4
 (1,2,2) => 1 * 2 * 2 = 4
 ```
 
 Jak to interpretować? Tak jak robiliśmy to wcześniej. Bool to 2 ... a 1 to... Void, pusta krotka! Tak więc te typy to odpowiednio:
 
 ```
 (Bool, Bool, Void) => 2 * 2 * 1 = 4
 (Bool, Void, Bool) => 2 * 1 * 2 = 4
 (Void, Bool, Bool) => 1 * 2 * 2 = 4
 ```
 
 No dobra, ale co to oznacza? Znaczy to tyle, że _dodanie instancji typu Void nie wnosi nowych informacji_. Co więcej widać, że właściwość mnożenia została zachowana dla tej struktury. _Dodawanie Void jest jak mnożenie razy 1_.
 
 Co w wypadku mnożenia przez zero? Aby nieco zagęścić zapis przedstawię krotkę `(Bool, Never)`, którą możemy w tym zapisie przedstawić jako `2 * 0`. Wynikiem tej operacji jest oczywiście zero. Natomiast w świecie typów oznacza to, że **nie możemy stworzyć instancji tego typu**!
 
 Nie wierzysz mi? To proszę uruchom program i sprawdź:
 */

run ("🔑 2 * 0"){
    let _: (Bool, Never) // = type your instance here if you can
    print("did it work?")
}

/*:
 A więc faktycznie i w świecie typów ta właściwość została zachowana dla mnożenia!
 
 ## Praktyczne Zastosowanie
 
 Wszystko cudownie natomiast _po co to komu_? Jeżeli pomyślisz o programowaniu jak właśnie o takich wyrażeniach algebraicznych jak w szkole. To jasne stanie się, że można je przekształcać. Upraszczać do formy _bardziej zrozumiałej_. Brzmi trochę jak **refactor**. Zmieniamy strukturę bez zmiany zachowania.
 
 ---
 
 ### Malutka dygresja.
 
 Grzebiąc w Internecie można się spotkać z określeniem _product_ oraz _coprodcut_. Powstaje naturalne pytanie _co to takiego?_
 
 A więc przedrostek _co_ (czyt. "ko") oznacza coś przeciwnego (dziedzina i przeciwdziedzina). Coproduct to jest coś przeciwnego produkt-owi. I to coś to właśnie **sum types** czyli dodawanie. Ciągnąc to dalej to _cosum_ (czyt. "kosum") to by było przeciwieństwo dodawania czyli mnożenie.
 
 Ciężko powiedzieć dlaczego akurat operacja mnożenia jest tą _wybraną_. Może to ma związek z tym, że wiele języków ma klasy i struktury a niekoniecznie enumeracje. A może po prostu _tak wyszło_.
 
 Najważniejsze aby zapamiętać, że _coproduct_ to zwykła _suma_ w świecie algebraicznych typów danych.
 
 ---
 
 ## To dopiero mniejsza połowa
 
 Są jeszcze co najmniej dwa inne (być może więcej) _byty_ ze świata algebry, które mapują się do świata programowania. Na pewno jest tego _trochę_ ze świata logiki ale może innym razem 🤓
 
 ### Potęgowanie
 
Dla przypomnienia powiedzmy mamy taki typ:
 
 */

enum TimeOfDay: CaseIterable {
    case morning
    case day
    case night
}

/*:
 `TimeOfDay` możemy zapisać jako `3`. Wiemy, że `Bool` można zapisać jako `2`. Pytanie brzmi: _ile implementacji można napisać funkcji:_`(TimeOfDay) -> Bool`?
 
 Policzmy:
 */

func timeToBool1(_ time: TimeOfDay) -> Bool {
    switch time {
    case .morning: return true
    case .day    : return true
    case .night  : return true
    }
}

func timeToBool2(_ time: TimeOfDay) -> Bool {
    switch time {
    case .morning: return false
    case .day    : return true
    case .night  : return true
    }
}

func timeToBool3(_ time: TimeOfDay) -> Bool {
    switch time {
    case .morning: return true
    case .day    : return false
    case .night  : return true
    }
}

func timeToBool4(_ time: TimeOfDay) -> Bool {
    switch time {
    case .morning: return true
    case .day    : return true
    case .night  : return false
    }
}

func timeToBool5(_ time: TimeOfDay) -> Bool {
    switch time {
    case .morning: return false
    case .day    : return false
    case .night  : return true
    }
}

func timeToBool6(_ time: TimeOfDay) -> Bool {
    switch time {
    case .morning: return true
    case .day    : return false
    case .night  : return false
    }
}

func timeToBool7(_ time: TimeOfDay) -> Bool {
    switch time {
    case .morning: return false
    case .day    : return true
    case .night  : return false
    }
}

func timeToBool8(_ time: TimeOfDay) -> Bool {
    switch time {
    case .morning: return false
    case .day    : return false
    case .night  : return false
    }
}

/*:
Ostatnia funkcja ma numer `8` i tak się składa, że gdy podniesiemy 2^3 to otrzymamy 8. Tak więc _w pewnym sensie_ `Bool` podniesiony do potęgi `TimeOfDay` jest _równoznaczny_ funkcji (w programowaniu) `(TimeOfDay) -> Bool`.
 
 Zapisując to bardziej abstrakcyjnie, ale może nieco czytelniej:
 
**Funkcja `(A) -> B` w świecie algebry jest równoznaczna operacji potęgowanie `B^A`**.
 
 Kolejność typów jest odwrócona. Tak więc skoro 2^3 daje 8 i faktycznie mamy 8 funkcji to zobaczmy ile jest możliwych implementacji funkcji `(Bool) -> TimeOfDay`. Z tego co wiemy to powinno ich być 3^2 a więc:
 */

func boolToTime1(_ bool: Bool) -> TimeOfDay {
    switch bool {
    case true : return .morning
    case false: return .morning
    }
}

func boolToTime2(_ bool: Bool) -> TimeOfDay {
    switch bool {
    case true : return .day
    case false: return .morning
    }
}

func boolToTime3(_ bool: Bool) -> TimeOfDay {
    switch bool {
    case true : return .night
    case false: return .morning
    }
}

func boolToTime4(_ bool: Bool) -> TimeOfDay {
    switch bool {
    case true : return .morning
    case false: return .day
    }
}

func boolToTime5(_ bool: Bool) -> TimeOfDay {
    switch bool {
    case true : return .day
    case false: return .day
    }
}

func boolToTime6(_ bool: Bool) -> TimeOfDay {
    switch bool {
    case true : return .night
    case false: return .day
    }
}

func boolToTime7(_ bool: Bool) -> TimeOfDay {
    switch bool {
    case true : return .morning
    case false: return .night
    }
}

func boolToTime8(_ bool: Bool) -> TimeOfDay {
    switch bool {
    case true : return .day
    case false: return .night
    }
}

func boolToTime9(_ bool: Bool) -> TimeOfDay {
    switch bool {
    case true : return .night
    case false: return .night
    }
}


/*:
Zobaczmy inne właściwości algebraiczne funkcji i jak przejawiają się one w Swift.
 
 Wiemy, że cokolwiek podniesione do potęgi pierwszej daj to cokolwiek: `45^1 = 45 => T^1 = T`.
 
 Jak się to tłumaczy na świat funkcji? A więc mamy takie wyrażenie: `T^1`. Wiemy, że `1` w świecie programowania, a konkretnie Swift, to pusta krotka czyli `Void`. Otrzymamy z tego takie wyrażenie: `T^Void`.
 
 Aby było nieco bardziej konkretnie za T podstawie `String` i otrzymam wyrażenie: `String^Void`. String podniesiony do potęgi Void. Brzmi bardzo dziwnie, jednak zróbmy ten jeszcze jeden krok. Zapiszmy to jako funkcję:
 */

let mysteryFunction: () -> String

/*:
 Ten typ mówi nam, że mogę stworzyć instancję typu String _z powietrza_. I owszem istnieje taka funkcja:
 */

mysteryFunction = String.init

run("🐦 mystery string") {
    print(
        "Mystery string is empty?", mysteryFunction().isEmpty
    )
}

/*:
 Trzeba przyznać, że jest to troszeczkę zaskakujące, że te oba światy tak się przenikają. Co więcej zachęcam do poszukania innych równoważności np. _cokolwiek podniesione do potęgi zerowej daje jeden_ `T^0 = 1`. W świecie funkcji to znaczy: `(Never) -> T = Void`. Trochę to absurdalne 😉
 
 Kolejne _prawo_ znane z działań na potęgach to _potęgowanie potęg_. Wykonuje je się wykorzystując wzór: `a^b^c = a^(b*c)`. W tym momencie nie powinno nikogo dziwić, że można przetłumaczyć ten zapis na funkcje: `(C) -> (B) -> A = (B,C) -> A`. Już kiedyś opowiadaliśmy o tym kształcie w świecie funkcji. Jest to **curring**!
 
# Podsumowanie
 
 To jest tylko część opowieści bo jest tego znacznie więcej!
 
 ```
 
                             │
                    Algebra  │  Types
 ────────────────────────────┼────────────────────────────
                             │
                        Sum  │  Enum
                             │
                    Product  │  Class | Struct | Tuple
                             │
               Exponentials  │  Functions
                             │
   Functions (like in math)  │  Generics
                             │
              Taylor Series  │  Recursive Data Types
                             │
                Derivatives  │  Zippers
                             │
 
 ```
 
 Przyznam, że gdybym wiedział to wszystko to troszeczkę bardziej uważałbym na lekcjach matematyki.
 
 Ta wiedza na pierwszy rzut oka może się wydawać _ciekawostką_. Zapewniam, że taka nie jest. Widać kiedy język jest wymyślony a kiedy _odkrywany_. To przekłada się bardzo na komfort pracy i możliwość ekspresji.
 
 Co może mniej oczywiste to, że **pisząc programy uprawiamy matematykę**. Tych nawiązań jest znacznie więcej i przekładają się w dużym skrócie do tego, że można potraktować kompilator jak asystenta, który pomoże udowodnić, że program działa zgodnie z założeniami.
 
 Można też to wykorzystać do **takiego modelowania danych aby złe kombinacje typów się nie kompilowały**.
 
 Jest to _problem_ dużo szerszy niż to co tu zostało poruszone, ale teraz już wiesz! Idź i szukaj dalej (hint: theorems for free, Curry-Howard isomorphism).

 # Linki
 
 * [PointFree - Algebraic Data Types #4](https://www.pointfree.co/episodes/ep4-algebraic-data-types)
 * [PointFree - Algebraic Data Types Exponents](https://www.pointfree.co/episodes/ep9-algebraic-data-types-exponents)
 * [PointFree - Algebraic Data Types Generics and Recursion](https://www.pointfree.co/episodes/ep19-algebraic-data-types-generics-and-recursion)
 * [Swift NonEmpty Array](https://github.com/pointfreeco/swift-nonempty)
 * [Functional Programming With Kotlin and Arrow — Algebraic Data Types](https://www.raywenderlich.com/11593767-functional-programming-with-kotlin-and-arrow-algebraic-data-types)
 * [Algebraic data types for fun and profit by Clément Delafargue](https://youtu.be/EPxi546vVHI)
 * [Algebraic data types aren't numbers on steroids](https://blog.ploeh.dk/2020/01/20/algebraic-data-types-arent-numbers-on-steroids/)
 * [Zippers by Tony Morris - pochodna w typach](https://youtu.be/HqHdgBXOOsE)
 * [Haskell Zippers](https://hackage.haskell.org/package/zippers)
 * [Making illegal states unrepresentable](https://oleb.net/blog/2018/03/making-illegal-states-unrepresentable/)
 * ["Propositions as Types" by Philip Wadler](https://youtu.be/IOiZatlZtGU)
 * [Functional and Algebraic Domain Modeling - Debasish Ghosh - DDD Europe 2018](https://youtu.be/BskNvfNjU_8)
 * [ADTs For The Win! by Noel Markham](https://youtu.be/oxBrEzb_i9A)
 * [Scala Toronto - Functional Domain Modeling with Effects by Debasish Ghosh](https://youtu.be/vKrCdO5NgrA)
 * [Category Theory Overview - Bartosz Milewski](https://www.youtube.com/watch?v=lJFUdWi3mDs&list=PLVtoy5GC9F9n8mHITu9EN0eHcxvq91EOn)
 * [George Wilson - When Less is More and More is Less: Trade-Offs in Algebra](https://youtu.be/VXl0EEd8IcU)
 * [Far more than you've ever wanted to know about ADTs by Nicolas Rinaudo at FP in the City Conference](https://youtu.be/MqGWb7OvVqs)
 * [Contravariant functors are Weird](https://sanj.ink/posts/2020-06-13-contravariant-functors-are-weird.html)
 */

//: [Next](@next)

print("🍀")
