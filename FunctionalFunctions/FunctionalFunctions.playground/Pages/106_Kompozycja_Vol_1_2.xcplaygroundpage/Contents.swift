
/*:
 # Kompozycja funkcji
 Często spotkać się można ze twierdzeniem, że kompozycja jest dużo lepsza od dziedziczenia. Warto się zatrzymać na chwilę i zastanowić _"dlaczego?"_.

 Jeżeli do budowania programów będziemy używać dziedziczenia to możemy skończyć z bardzo rozbudowaną hierarchią w której są dziedziczone zachowania, które nie są potrzebne. Można powiedzieć, że dziedziczymy śmieciowe DNA, które jest ale do niczego nam wcale nie służy.

 Co jeszcze gorsze bardzo trudno jest potem dokonać zmian w takiej hierarchii. Jeżeli na poziomie projektowania został popełniony błąd to może się okazać, że musimy nauczyć się z nim żyć.

 To co byśmy chcieli osiągnąć to tak zbudować naszą aplikacje/system aby tego śmieciowego DNA było jak najmniej. Oraz aby w razie potrzeby można było zmienić sposób w jaki są połączone ze sobą różne fragmenty aplikacji.

 Tu właśnie przychodzi z pomocą kompozycja. Zgodnie z tym pomysłem bierzemy tylko to co potrzebujemy. Łączymy to co jest dostępne w jedną całość tworząc nowe komponenty.

 Gdy skupimy się tylko na podejściu funkcyjnym to okaże się, że funkcje po sobie nie mogą dziedziczyć. Ze swojej natury więc uniemożliwiają wpadnięcie w "pułapkę" dziedziczenia.

 To co możemy robić to je ze sobą komponować. I teraz chcę pokazać jak :)

 ---

 Zaczniemy od zdefiniowania prostych funkcji:
 */

func  incr(_ x: Int) -> Int { x + 1 }
func multi(_ x: Int) -> Int { x * x }

/*:
 Spróbujmy za pomocą tych funkcji wyrazić kilka prostych równań:
 */
//: x + 1
incr(1)

//: x * x
multi(2)

//: (x^2) + 1
incr(multi(2))

//: ((x + 1)^2)^2 + 1
incr(multi(multi(incr(0))))

/*:
A co gdy ostatnie równanie zamienimy na:

(x + 2)^4 + 3

Zobaczmy jak możemy podejść do tego problemu.
 */

let zero = 0

assertEqual(1,           incr(zero)  )
assertEqual(2,      incr(incr(zero)) )
assertEqual(3, incr(incr(incr(zero))))

assertEqual(  4,               multi(2) ) // 2^2
assertEqual( 16,         multi(multi(2))) // 2^4
assertEqual(256,  multi(multi(multi(2)))) // 2^8

/*:
 Jak widać bez problemu możemy budować odpowiednie elementy zagnieżdżając odpowiednio wywołania funkcji. Niestety jest to mało wygodne i mało czytelne. Potrzebujemy narzędzi za pomocą których zbudujemy sobie to co dokładnie jest nam potrzebne.

 Mamy tu pewien wzorzec w kodzie, który się powtarza. Postaramy się go nazwać i zamknąć w jednym kawałku. Użyjemy do tego funkcji wyższego rzędu.
 */

func compose<A,B,C>(
    _ f: @escaping (A) -> B,
    _ g: @escaping (B) -> C
    ) -> (A) -> C {
    return { a in
        let b = f(a)
        let c = g(b)
        return c
    }
}

/*:
 W tej funkcji zamknęliśmy zachowanie które polega na wywołaniu pierwszej funkcji i wyniku przekazaniu do drugiej.
 */

let addTwo   = compose(incr, incr)
let addThree = compose(addTwo, incr)
let tetra    = compose(multi, multi)

assertEqual(     2*2,  multi(2))
assertEqual( 2*2*2*2,  tetra(2))
assertEqual(0 + 2,   addTwo(zero))
assertEqual(0 + 3, addThree(zero))

let addTwoAndTetra = compose(addTwo, tetra)
let final = compose(addTwoAndTetra, addThree)

assertEqual(4, final(-1))
assertEqual(19, final(0))
assertEqual(84, final(1)) // 3^4 + 3 => 9*9 + 3 => 81 + 3 => 84

/*:
 To samo, co prawda mniej czytelnie, możemy zapisać jako jedne wyrażenie:
 */

// (x + 2)^4 + 3
// >>> Pluming, że kapanie czy plumbing jako wodociąg/hydraulike? >>>
let composed =
compose(           // <-- pluming🚰 (x + 2)^4 + 3
    compose(       // <-- pluming🚰 (x + 2)^4
        compose(   // <-- pluming🚰  x + 2
            incr,  // <-- basic block 🧱 +1
            incr   // <-- basic block 🧱 +1
        ),
        compose(   // <-- pluming🚰 ^4
            multi, // <-- basic block 🧱 ^2
            multi  // <-- basic block 🧱 ^2
        )
    ),
    compose(      // <-- pluming🚰 +3
        compose(  // <-- pluming🚰 +2
            incr, // <-- basic block 🧱 +1
            incr  // <-- basic block 🧱 +1
        ),
        incr      // <-- basic block 🧱 +1
    )
)

assertEqual(composed(-1), final(-1))
assertEqual(composed(zero), final(zero))
assertEqual(composed( 1), final( 1))

/*:
W obu przypadkach uzyskaliśmy bardzo duże reużycie kodu. Za pomocą już istniejących elementów opisaliśmy nowe kawałki. Można nawet zaryzykować stwierdzenie, że z poprawnych (przetestowanych) elementów (funkcje, typy) łączonych w ten sposób automagicznie dostajemy poprawne zachowanie.

 Pierwszy przykład dużo lepiej się czyta. Drugi z kolei pokazuje jak wygląda struktura aplikacji/funkcji. Widać też jasno, że mamy dużą swobodę w komponowaniu tej struktury. Co więcej nie jesteśmy _skazani_ tylko na zdefiniowane wcześniej elementy. Możemy je zdefiniować adhoc.
*/

// (x + 3)^3 + 10

let composed2 =
compose(
    compose(
        { (x: Int) in x + 3 },
        { (x: Int) in x * x * x }
    ),
    { (x: Int) in x + 10 }
)

assertEqual(10, composed2(-3))
assertEqual(37, composed2( 0))

/*:
 ## Operatory

 Teraz wejdziemy na nieco bardziej śliski grunt ;) Jak widać kompozycja jest spoko ale na dzień dzisiejszy ma trochę hałaśliwe API. Chcielibyśmy troszeczkę tą hydranikę schować. Nie możemy jej się pozbyć bo bez niej nic by nie działało ale nie chcemy aby się tak rzucała w oczy 👀.

 Wykorzystamy do tego *operatory*. Tak na prawdę to operator też jest funkcją. Jedyna różnica to, że może być wywołana w _specjalny_ sposób.

 Zanim zdefiniujemy operator kompozycji to mamy jeszcze jeden wzorzec, który możemy nazwać i opakować tym razem w operator _pipe forward_ *|>*.
 */

precedencegroup ForwardApplication {
    associativity: left
}

infix operator |>: ForwardApplication

public func |> <A, B>(x: A, f: (A) -> B) -> B {
    f(x)
}

/*:
 Operator ten służy do przekazania wartości do funkcji. Występuje też np. w F# i powinien wyglądać znajomo dla każdego kto choć raz używał operatora _pałki_ w terminalu ;)
 */

1 |> incr |> { x in x * x } |> incr

1
    |> incr
    |> { $0 * $0 }
    |> incr

/*:
Co ważne w każdym z tych kroków wywołujemy funkcję i jej wynik przekazujemy do kolejnej. Tym prostym zabiegiem mamy ukrytą hydraulikę pod operatorem i możemy bardzo ekspresyjnie pisać kod o który nam chodzi.

 Zajmijmy się teraz funkcją compose. Ją też chcielibyśmy schować pod operatorem:
*/

precedencegroup ForwardComposition {
    higherThan: ForwardApplication
    associativity: right
}

infix operator >>>: ForwardComposition

public func >>> <A, B, C>(
    _ f: @escaping (A) -> B,
    _ g: @escaping (B) -> C)
    -> (A) -> C {
        { a in a |> f |> g }
}

/*:
To jest dokładnie ta sama iplemyntacja co wcześniej tylko zapisana za pomocą już wcześniej zdefiniowanego operatora. Mam nadzieję, że tu jasno widać, że to jest tylko przekazanie wartości z jednej funkcji do drugiej :)

Co jest ważne ten operator definiuje nową funkcję. Więc możemy komponować operacje nie uruchamiając żadnych obliczeń.
*/

// (x + 3)^3 + 10
let expression = incr
    >>> incr
    >>> incr
    >>> { x in x * x * x }
    >>> { $0 + 10 }

type(of: expression)

-3 |> expression

/*:
Mamy do dyspozycji bardzo fajne narzędzie. Jak się można domyślać nie jedyne z jakim się jeszcze spotkamy.

 Funkcje jakie do tej pory komponowaliśmy ze sobą mają dość specyficzny kształt. Przyjmują jeden argument i zwracają jedną _wartość_. Niestety nie wszystkie funkcje z jakimi pracujemy są właśnie w takim kształcie. Tym natomiast zajmiemy się troszeczkę później. Najpierw uwolnimy sobie kilka znanych nam funkcji po to aby były właśnie bardziej komponowalne :)

 ---

 Pierwszą funkcję jaką uwolnimy jest _map_ na tablicy.  Transformujemy istniejące API do formy bardziej przyjaznej kompozycji.
*/

func map<A, B>(_ array: [A], _ transform: (A) -> B) -> [B] {
    array.map(transform)
}

/*:
 To co można usłyszeć o funkcji map to to, że podnosi jakąś funkcje do pracy w innym kontekście. W języku _language_ można się spotkać z pojęciem *lift*. Nasz operator będzie odzwierciedlał to _podnoszenie_.
 */

precedencegroup FunctorialApplication {
    associativity: left
}

infix operator <^>: FunctorialApplication
public func <^> <A, B>(
    _ a: [A],
    _ f: @escaping (A) -> B
    )
    -> [B] {
         map(a,f)
}

/*:
 Z tego operatora korzystamy w ten sposób:
 */

[1,2,3]
    <^> incr
    <^> incr
    <^> incr

/*:
 Funkcja _incr_ ma typ *(Int) -> Int*, czyli nie ma żadnego pojęcia o tym czym są tablice. Jednak za pomocą operatora *<^>* czyli funkcji _map_ *podnieśliśmy* ją do działania z wartościami umieszczonymi w tablicy.

 Co więcej zachowaliśmy czytelną składnie i bez problemu udało się wywołać kilka operacji na raz.
 */

public func <^> <A, B>(
    _ a: A?,
    _ f: @escaping (A) -> B
    )
    -> B? {
        return a.map(f)
}

Int?(42)
    <^> incr
    <^> incr
    <^> incr

/*:
 Po raz kolejny użyliśmy tej samej funkcji, która pracuje na _samych intach_ i *podnieśliśmy ją do kontekstu braku wartości*, który w systemie typów jest przedstawiony jako _Optional_.

Przyglądając się uważnie to możemy dojść do wniosku, że *map*a bierze wartość (wynik operacji) z lewej strony i wkłada do funkcji z prawej. Ubierając to w jeszcze inne słowa, funkcja _map_ abstrahuje nam wywołanie funkcji! Function application w języku _language_.

 To również możemy zapisać:
 */

public func <^> <A, B>(
    _ a: A,
    _ f: @escaping (A) -> B
    )
    -> B {
        f(a) // dokładnie to samo co operator `|>
}

1 <^> incr <^> incr <^> incr

/*:
Możemy nawet wykorzystać już istniejące funkcje do kompozycji:
 */

func id<A>(_ a: A) -> A { return a }

1
     |> [incr, incr, incr             ].reduce(id, compose)
1
    <^> [incr, incr, incr, { $0 * 10 }].reduce(id, compose)

1
     |> [incr, incr, incr             ].reduce(id, >>>)
1
    <^> [incr, incr, incr, { $0 * 10 }].reduce(id, >>>)

/*:

W jednej linijce powiedzieliśmy, że chcemy "wsadzić" 1 do złączenia całej tablicy funkcji w jedną! Powiedzieliśmy **co** bez mówienia **jak**. Funkcja `id` okazała się bardzo użyteczna. Za jej pomocą tworzymy `Monoid` dla kompozycji.

Do tego jeżeli się uprzemy to możemy używać tego samego operatora czyli `map` (chociaż intencja może być jaśniejsza przy `|>`).

 ## Key Path

 Jest jeszcze jedna funkcjonalność języka, którą możemy zmapować tym razem do świata funkcji. To są *KeyPath*y. Zobaczmy co to jest:
 */

struct Person {
    let name: String
    let age: Int
}

let nameKeyPath = \Person.name
type(of: nameKeyPath)

let ageKeyPath: KeyPath<Person, Int> = \Person.age

/*:
 To co mamy w tych stałych to referencje do tych _properties_. Swift posiada specjalne API do pracy z KeyPath-ami.
 */

let person = Person(name: "Brajanusz", age: 42)

person[keyPath: nameKeyPath]
person[keyPath: ageKeyPath]

/*:
 Wiele API w Swift (filter, reduce etc.) pujmuje jako argument funkcje a nie KeyPath (chociaż to ma się podobno zmienić). Więc chcemy jakoś _podnieść_ KeyPathy do świata funkcji.
 */

prefix operator ^
public prefix func ^<Root, Value>(
    _ kp: KeyPath<Root,Value>)
    -> (Root) -> Value {
    return { root in root[keyPath: kp] }
}

person
    <^> ^\.name
    <^> { $0.uppercased() }

person
    <^> ^\.name
    <^> String.uppercased

/*:
 Jak widać zmieniliśmy KeyPath w zwyczajną funkcję i teraz możemy użyć jej wszędzie tam gdzie API spodziewa się funkcji. Bez czekania na odpowiednią wersję Swift-a ;)
 */

let users = [
    Person(name: "Brajanusz", age: 42),
    Person(name: "Dżesika"  , age: 36),
    Person(name: "Waldemar" , age: 28)
]

users
    .map(^\.name)

users
    .map(^\.age)

users
    .filter(^\.age >>> { $0 > 30 })
    .map(^\Person.name)

let isGreaterThan30Predicate: (Int) -> Bool = { $0 > 30 }

users
    .filter(^\.age >>> isGreaterThan30Predicate)
    .map(^\Person.name)

/*:
 Tego typu zapis jest to coś co *TRZEBA* trochę poćwiczyć. Najlepiej jest zacząć od małych fragmentów kodu. Intuicja z czego jak korzystać przychodzi tym szybciej im częściej się tego używa.

 Po raz kolejny przykład jest z gatunku tych szkolnych jednak widać jak pozwala być bardzo ekspresyjnym.

 Z KeyPath tworzymy funkcję `(Person) -> Int`, która "wyciąga" ze struktury wiek. Tą funkcje komponujemy z naszym predykatem `{ $0 > 30 }`. Co po kompozycji daje nam typ: `(Person) -> Bool`, który jest wymagany przez funkcję/kombinator _filter_. To złożenie odpowiada na pytanie czy ktoś ma więcej niż 30 lat.

 Kolejna w łańcuszku mpa-a (moglibyśmy użyć operatora) _wyciąga_ imiona tych osób.

 Finalnie cały _pipeline_ wyciąga imiona osób, które mają więcej jak 30 lat.

 Powtórze się. Mówimy co, nie mówimy jak :) I takiego kodu Wam życzę!

 ## Podsumowanie

 Przeszliśmy kawał drogi tym razem. Zobaczyliśmy coś czego zbyt często się nie ogląda ;) Czy wszystko było piękne? To już jest dyskusyjne, ale na pewno widać, że o kodzie można myśleć inaczej niż do tej pory. Jest cały świat pomysłów, które tylnymi drzwiami wchodzą do Swift-a. Dobrze jest wiedzieć skąd pochodzą oraz w czym są dobre a gdzie stwarzają problemy.

 Usłyszeliśmy też kilka trudnych i strasznych wyrazów. One są tu po to nie żeby pokazać, że o ja pierdole jacy jesteśmy mądrzy ;) ale po to aby było wiadomo czego szukać w sieci jak kogoś temat zainteresuje ;) No jeszcze można użyć na rozmowie o pracę i dostać łatkę kosmity ;)

 # Linki
 
 Implementacja operatorów w większości jest inspirowana z:
 [pointfreeco](https://github.com/pointfreeco)

 */




