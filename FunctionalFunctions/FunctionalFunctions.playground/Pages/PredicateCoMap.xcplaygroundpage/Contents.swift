//: [Previous](@previous)

import Foundation

/*:
 # Predicate & CoMap

Dziś rzucimy okiem na nowy _typ_ który jest przy okazji pozwoli nam otworzyć drzwi do jeszcze jednego rodzaju kompozycji.

Bez zagłębiania się w szczegóły można powiedzieć, że predykat to takie zadnie któremu możemy jednoznacznie jednoznacznie przypisać wartość _prawda_ lub _fałsz_. Możemy powiedzieć _temperatura powietrza w dniu X o godzinie Y w mieście Z wynosi 21 stopni Celsjusza_. Podstawiając za zmienne konkretne wartości i porównując je z zapisanymi danymi (dla uproszczenia powiedzmy, ze posiadamy te dane) możemy powiedzieć czy to prawda czy fałsz.

 Język naturalny bywa kłopotliwy. Co w wypadku zdania "teraz jest ciepło". Czy można jednoznacznie przypisać wartość prawda lub fałsz do takiego zdania? Niestety nie. Ani nie wiemy kiedy jest teraz (gdy to piszę to jest inne teraz niż gdy to czytasz) ale też dla mnie _ciepło_ może oznaczać coś zupełnie innego niż dla Ciebie.

 Z tego powodu uciekniemy w bardziej poukładany świat i będziemy mówić, że predykatem jest _funkcja przyjmująca jakieś argumenty i zwracająca instancję typu Bool_. W Swift można zapisać to tak:

 */

run {
    func predicateExample1(i: Int)         -> Bool { true }
    func predicateExample2(i: Int)         -> Bool { i > 21 }
    func predicateExample3(i: Int, j: Int) -> Bool { true }
    func predicateExample4<A>(i: A)        -> Bool { true }
}

/*:

 Ogólnie można zapisać ten typ tak:

```swift
 (A)    -> Bool
 (A,B)  -> Bool
 (A...) -> Bool
 ```

 Ilość argumentów na wejściu nie ma znaczenia. Zawsze możemy je zgrupować w jedną strukturę i potraktować ją jako jeden parametr generyczny (zachęcam do rzucenia okiem na filmy o algebraicznych typach danych; product types).

W serii o wariancji, w filmiku o określaniu czy dany generyk znajduje się na pozycji covariant czy contravariant posługiwaliśmy się taką sztuczką, że wszystko co było na lewo od strzałki miało znak ujemny a na prawo dodatni. Jeżeli typ finalnie był _ujemny_ to znaczy, że najprawdopodobniej możemy dla niego napisać funkcję contra map.

 ## Mały problem 🤔

 Chcemy napisać funkcję `contramap` dla typu `(A) -> Bool`. Swift ma mechanizm rozszerzeń które pozwalają na dopisanie dodatkowych metod, property dla danego typu. Natomiast nie działa to z typami funkcyjnymi.

 Rozwiązanie jest zaskakująco proste i może nawet eleganckie. Musimy zdefiniować swój własny typ, który będzie reprezentować predykat:

 */


struct Predicate<Element> {
    let check: (Element) -> Bool
}

/*:

Mamy pudełko na funkcje i na tym pudełku już można dopisać rozszerzenia 😎

 ## Dygresja

 Zanim przejdziemy do funkcji contramap zastanówmy się jak można wykorzystać predykat. Przykład jest szkolny ale potem zobaczymy, że z prostych rzeczy można budować wspaniałe struktury.

 _Normalnie_ do odpowiedzenia na pytanie czy coś się w czymś zawiera użyjemy struktury Set (zbiór). Możemy się jej odpytać czy coś należy do tego zbioru czy nie. Jeżeli naszym pytaniem by było _czy liczba X jest parzysta_ to musimy skonstruować zbiór zawierający wszystkie liczby parzyste. Takie rozwiązanie wymaga od nas użycia ogromnej ilości pamięci (nawet jak ograniczmy się tylko do wszystkich liczb jakie można przechować w Int).

 Oczywiście nikt z Was by tego w ten sposób nie zrobił. Problem jest z byt trywialny i każdy od razu by napisał funkcję sprawdzającą czy reszta z dzielenia przez 2 jest równa zero. Natomiast to już jest jak najbardziej predykatem!

 */

run("🎭 one way of predicating") {

    // Here we are creating a predicate
    let allEven = Predicate { (element: Int) -> Bool in
        element % 2 == 0
    }

    // We must have something to check our predicate on
    let numbers  = [ 1,2,3,4 ]

    // we can use map to get the results
    let contains = numbers.map( allEven.check )

    // just "fancy" presentation that will show a number
    // and result of calling a predicate with it
    print(
        "Is number even:",
        zip(numbers, contains)
            |> Array.init
    )
}

/*:

 Wiem, że przykład jest trywialny jeżeli chodzi o to _co to robi_. Po raz kolejny _wielkim pomysłem_ jest kompozycja. Na tym proszę się skup najbardziej a nie czy ta liczba jest parzysta czy nie.

 Aby nasze oczy nabrały wprawy z operatorami zapiszemy to inaczej (jeżeli potrzebujesz przypomnienia operatorów to są w playliście funkcyjnej). Operatory pozwalają na mniej hałaśliwą kompozycje funkcji.

 Rozbijemy ten predykat na mniejsze kawałki, które łatwo przetestować i połączymy w wiekszą całość.

 Predykat ma fragment który sprawdzał czy reszta z dzielenia jest równa zero. Możemy ten fragment zamknąć w osobnej funkcji:
 */

let isZero: (Int) -> Bool = { $0 == 0 }
assertTrue (  0 |> isZero)
assertFalse(  1 |> isZero)
assertFalse( -1 |> isZero)
assertFalse( 10 |> isZero)
assertFalse(-10 |> isZero)

/*:
Jak widać jest ona predykatem (ma _kształt_ o którym wspominałem wcześniej) jednak w kontekście naszego przykładu to czysty przypadek :)

 Potrafimy powiedzieć czy coś jest zerem. Teraz musimy jakoś opisać to jak wygląda wynik reszty z dzielenia. Niestety typ operatora `%` nie sprzyja kompozycji:
 */

let _ : ((Int, Int) -> Int) = (%)

/*:

 Nie dość, że potrzebujemy 2 argumentów to jeszcze chcemy _zapiec_ jeden z nich. Ale to nie koniec problemów. Pierwszym argumentem jest dzielna a drugim jest dzielnik i to właśnie ten drugi argument chcemy _wypalić_.

Tego typu problemy rozwiązywaliśmy w serii funkcyjnej. Konkretnie w odcinkach o masowaniu funkcji oraz o partial application. Nie pozostało mi nic innego jak wykorzystać je aby stworzyć funkcję która będzie przyjmować Int i zwracać resztę z dzielenia przez 2:
 */

let remainderDivByTwo: (Int) -> Int = partial( flip(%), 2)
assertEqual(10 |> remainderDivByTwo, 0)
assertEqual( 9 |> remainderDivByTwo, 1)
assertEqual( 8 |> remainderDivByTwo, 0)
assertEqual( 7 |> remainderDivByTwo, 1)
assertEqual( 6 |> remainderDivByTwo, 0)
assertEqual( 5 |> remainderDivByTwo, 1)
assertEqual( 4 |> remainderDivByTwo, 0)
assertEqual( 3 |> remainderDivByTwo, 1)
assertEqual( 2 |> remainderDivByTwo, 0)
assertEqual( 1 |> remainderDivByTwo, 1)
assertEqual( 0 |> remainderDivByTwo, 0)

/*:
Operator `flip` zamienia argumenty miejscami. Operator `partial` odpowiada za zapieczenie pierwszego argumentu do funkcji. Oczywiście można napisać taką wersję operatora `partial` która to będzie robić ale konwencja _zapiekania_ od pierwszego argumentu wydaje się bardziej _naturalna_.

 Mając te klocki można ten sam przykład napisać wykorzystując operator kompozycji funkcji `>>>`:
 */

run("🌵 break apart and combine") {
    let allEven = Predicate(
        check: remainderDivByTwo >>> isZero
    )

    let numbers  = [1,2,3,4]
    let contains = numbers.map(allEven.check)

    print(
        zip(numbers, contains)
            |> Array.init
    )
}

/*:

Wynik mamy ten sam. A więc wiemy, że kod _robi to samo_. To jednak nie jest takie ważne. Jak wspominałem najważniejsze jest _jak to robi_:

 - Zdefiniowaliśmy mały _otestowany_ kawałek _isZero_
 - Ponownie jest użyty kod zdefiniowany gdzieś indziej dla operatora _%_ reszta z dzielenia (i tam pewnie przetestowany 😅). Został w nim _zabetonowany_ drugi argument dzięki temu powstała funkcja **reprezentuje** teraz _resztę z dzielenia przez 2_
 - Użyty został operator kompozycji funkcji _>>>_ który deklaratywnie z wcześniej zbudowanych fragmentów odpowiada na pytanie _czy reszta z dzielenia czegoś przez 2 jest równa 0_

 Kwestią do rozważenia głęboko w sercu jest to czy taka kompozycja powinna posiadać testy unit-owe. Przecież wiemy, że nasza operacja kompozycji jest prawidłowa. Każdy z elementów też ma testy. Czy w tym wypadku na pewno trzeba pisać testy unit-owe do tej kompozycji? Czy tak dużo wniosą czy może jednak będą kolejnym kodem do utrzymania? Może lepsze jest sprawdzenie tej ścieżki w teście integracyjnym?

 Wróćmy do Predykatu. Widać jasno, że jedyne co robi to służy za _domek_/kontener dla funkcji `(Element) -> Bool`.
 */

run("🦙 why you wrap this") {
    let numbers  = [1,2,3,4]
    let contains = numbers.map(remainderDivByTwo >>> isZero)

    print(
        zip(numbers, contains)
            |> Array.init
    )
}

/*:
 Wynik jest ten sam. Więc po co? Można było mieć po prostu te funkcje i się z tym nie babrać.

 Tak! Masz całkowitą rację! W tym przypadku zwykła kompozycja funkcji jest jak najbardziej ok i działa i jest super. Ale my jesteśmy na froncie kompozycji! Chcemy komponować to czego nie komponował wcześniej nikt inny (tak na prawdę od dekad ludzie to znają)! I chcemy to robić z taką łatwością aby osoba, której to pokażemy wydała z siebie soczyste "Kurwa!" niczym Gerald gdy się dowiedział, że _ma dziecko_.

 Wracamy do początku tego odcinka. To co możemy zdefiniować dla struktury a nie możemy dla funkcji to... metody 😎 Konkretnie takie, które pozwalają nam użyć tego samego kodu ale _do czegoś innego_.

 Odpowiedzmy sobie na podobne pytanie. Zbuduj Predykat, który będzie zawierać _wszystkie możliwe String-i, których długość jest parzysta_.
 */

run("☠️ with out reuse of code") {
    let evenLenStrings = Predicate<String>{ string in string.count % 2 == 0 }

    let words  = ["a","aa","aaa","aaaa"]
    let contains = words.map( evenLenStrings.check )

    print(
        zip(words, contains)
            |> Array.init
    )
}

/*:
 Działa. Jednak gołym okiem widać, że można to zrobić troszeczkę lepiej. Co więcej łatwo zbudować _klocek_, który w sobie ma zakodowaną wiedzę czy coś jest parzyste czy nie.
 */

let evenNumbers: Predicate<Int> = Predicate(check: remainderDivByTwo >>> isZero)

/*:
 Teraz jakoś trzeba go _zmusić_ do pracy na String-ach a nie Int-ach.

 # Contramap

 Jest to rodzaj mapy, która zmienia nie wartości wyjściowe jak _zwykła_ mapa. A zmienia nam typ wartości wejściowych.

 */

extension Predicate {

    func contramap<NewInput>(
        _ f: @escaping (NewInput) -> Element
    ) -> Predicate<NewInput> {

        Predicate<NewInput>(check: f >>> self.check)

    }
}

/*:

 Na pierwszy rzut oka zaskakujący może być typ funkcji `f`. Jednak jest to logiczne. Skoro mam coś co jest predykatem dla np. typu `Int` a chcę aby *to samo* działało dla typu `String`, to muszę powiedzieć jak ze `String`a zrobić `Int`a. Na końcu chcę otrzymać Predykat String-ów.

 Czas na szybki przykład:
 */

run("👏🏻 comap") {
    let evenLenStrings: Predicate<String> = evenNumbers.contramap( \String.count )

    let words  = ["a","aa","aaa","aaaa"]
    let contains = words.map( evenLenStrings.check )

    print(
        zip(words, contains)
            |> Array.init
    )
}

/*:
 Ja jak pierwszy raz to zobaczyłem to pomyślałem sobie "Wow 😲". Jeden kawałek, który działa w świecie Int-ów można przenieść bardzo łatwo do świata String-ów.

 Inną nazwą z jaką można się spotkać na contra map-ę to: _comap_ oraz _pullback_. Z czego to drugie określenie jest _ogólniejsze_ niż comap-a. Natomiast jestem przekonany, że _dociekliwego_ developera zawiezie to w odmęty innych ciekawych pomysłów.

 Jak już tak dobrze idzie to dopiszmy sobie jeszcze dwa _kombinatory_ / _operatory_. Występują one w logice i aż się prosi aby były dostępne dla nas.
 */

extension Predicate {
    func or(_ other: Predicate<Element>) -> Predicate<Element> {
        Predicate<Element> { element in
            self.check(element) || other.check(element)
        }
    }

    func and(_ other: Predicate<Element>) -> Predicate<Element> {
        Predicate<Element> { element in
            self.check(element) && other.check(element)
        }
    }
}

/*:

Oba operatory zachowują się tak samo jak w logice. W sumie nie wiem czy jest coś więcej do powiedzenia o nich po za tym, że teraz można z mniejszych predykatów komponować większe.

Zbudujemy predykat, który odpowie na pytanie czy protokół jaki jest używany to HTTP. Będąc technicznie upierdliwym to będziemy zajmować się stringami ale...
 */

let   safeHttp = Predicate<String>{ $0 == "https" }
let unSafeHttp = Predicate<String>{ $0 == "http"  }

let isHttp = safeHttp.or(unSafeHttp)
assertTrue ( isHttp.check( "http"  ) )
assertTrue ( isHttp.check( "https" ) )
assertFalse( isHttp.check( "file"  ) )

/*:

 Nasze testy potwierdzają, że mniejszy kawałek działa zgodnie z tym jak zaplanowaliśmy. Cokolwiek związanego z HTTP jest rozpoznane a cokolwiek innego nie.

 Następne dwa _klocki_ odpowiedzą nam na pytanie czy to jest _nasza domena_ oraz czy w ścieżce znajduje się `user`. Technicznie cały czas porównujemy stringi gdyż jest to łatwiejsze i bardziej zrozumiałe.

 */

let isMyDomain = Predicate<String>{ $0 == "example.com" }
let isUserPath = Predicate<String>{ string in string.contains("user") || string.contains("User") }

/*:
Do rozpoznania ścieżki mogłem użyć 2 predykatów i je połączyć, ale bez przesady. Jak z dobrą potrawą sól i pieprz do smaku ;)

 Jak już zapewne czujesz będę chciał za pomocą tych predykatów zbudować predykat działający na instancji typu `URL`. Oczywiście nie jest to takie proste ponieważ niektóre property tego typu są opcjonalne. Potrzebujemy jeszcze jednego operatora...

 */

extension Predicate {
    var optional: Predicate<Element?> {
        Predicate<Element?> { element in element.map(self.check) ?? false }
    }
}

/*:
Tym razem operator zwraca nowy predykat, który jeżeli mamy `case .some` używa predykatu dla właściwego typu. Jeżeli natomiast `.none` to zwraca false.

 To, że tutaj zwracam `false` jest moją decyzją, konwencją, widzi mi się. Równie dobrze może być zwracane `true`. Wszystko zależy od tego jak chcę aby był traktowany przypadek gdy nie mam na czym zawołać funkcji predykatu. Może powinny istnieć dwa operatory?

Spróbujmy teraz za pomocą tych operatorów przenieść predykaty działające na String-ach do świata URL-li.
 */

run("👒 operator combinator") {

    /*:
     Schema jest opcjonalna więc musimy użyć operatora `optional`:
     */

    // 💥 Key path value type 'String?' cannot be converted to contextual type 'String'
//    let isSafeUserPath:Predicate<URL> =
//        safeHttp.contramap( \URL.scheme )



    var isSafeUserPath: Predicate<URL> =
        safeHttp.optional.contramap( \URL.scheme )

    assertTrue(isSafeUserPath.check( URL(string: "https://")! ) )
    assertFalse(isSafeUserPath.check( URL(string: "http://")! ) )

    /*:

     Gdy wiem, że schema jest HTTP to chciałbym wiedzieć czy URL wskazuje na moją domenę:

     */


    isSafeUserPath =
        safeHttp.optional.contramap(\URL.scheme)
            .and( isMyDomain.optional.contramap(\URL.host) )

    assertTrue(
        isSafeUserPath.check( URL(string: "https://example.com")! )
    )
    assertTrue(
        isSafeUserPath.check( URL(string: "https://example.com/some/path")! )
    )
    assertFalse(
        isSafeUserPath.check( URL(string: "http://example.com")! )
    )
    assertFalse(
        isSafeUserPath.check( URL(string: "https://notexample.com/some/path")! )
    )

    /*:
     W następnym kroku chciałbym wiedzieć jaki jest pierwszy komponent w ścieżce. Nie bój się. Użyje do tego wszystkiego co do tej pory mówiłem. Na końcu chciałbym mieć funkcję, która gdy dostanie instancje `URL` zwróci mi pierwszy komponent ścieżki. Może go zabraknąć więc zwracanym typem będzie `String?`:
     */

    let firstPathComponent: (URL) -> String? =
        \URL.pathComponents
        >>> { components in
            guard
                components.isEmpty == false
            else { return components }

            var copy = components
            copy.removeFirst()
            return copy
        }
        >>> \Array.first

    print(
        "firstPathComponent from given url is:",
        URL(string: "https://example.com/in-path/user")! |> firstPathComponent

            as Any
    )

/*:
 Tak wiem, gęsto :) Nie chodzi o to aby być kosmitą tylko zobaczyć, że ten mechaniczny kod z przepychaniem zmiennych do funkcji jest ukryty w tych operatorach. Do tego Swift sobie ładnie radzi z zamianą KeyPath-ów na funkcje. W sumie daje to taki efekt, że _nasz kod_ jest miedzy operatorami kompozycji `>>>`.

 Teraz możemy skleić to wszystko do kupy:
 */

    isSafeUserPath =
        safeHttp.optional.contramap( \URL.scheme )
            .and(
                isMyDomain.optional.contramap( \URL.host )
            )
            .and(
                isUserPath.optional.contramap( firstPathComponent )
            )

/*:
 Kochaj ale sprawdzaj powiadają. Zobaczmy czy to najnowsza wersja predykatu działa:
 */

    // True
    assertTrue(
        isSafeUserPath.check( URL(string: "https://example.com/user")! )
    )
    assertTrue(
        isSafeUserPath.check( URL(string: "https://example.com/User")! )
    )

    // False
    assertFalse(
        isSafeUserPath.check( URL(string: "https://example.com/hmm/user")! )
    )
    assertFalse(
        isSafeUserPath.check( URL(string: "https://example.com/hmm/User")! )
    )
    assertFalse(
        isSafeUserPath.check( URL(string: "http://example.com")! )
    )
    assertFalse(
        isSafeUserPath.check( URL(string: "https://notexample.com/some/path")! )
    )
    assertFalse(
        isSafeUserPath.check( URL(string: "http://")! )
    )
    assertFalse(
        isSafeUserPath.check( URL(string: "http://example.com/user")! )
    )
    assertFalse(
        isSafeUserPath.check( URL(string: "http://example.com/User")! )
    )
}

/*:
 # Podsumowanie

 Dziś zobaczyliśmy bardzo dużo. Na pewno _nowym_ pomysłem jest _contramap_a. _Kombinatory_ przewijały się tu i tam, ale chyba tak _jawnie_ o nich nie mówiliśmy. Zobaczyliśmy też, że czasami zrobienie kroku do tyłu (owinięcie funkcji w typ) sprawia, że otwierają się nam drzwi do kompozycji.


 # Linki

 * [PointFree Subscriber only - Contravariance](https://www.pointfree.co/episodes/ep14-contravariance)
 * [GitHub - PredicateSet](https://github.com/robrix/Set/blob/master/Set/PredicateSet.swift)
 * [PointFree - Some news about contramap](https://www.pointfree.co/blog/posts/22-some-news-about-contramap)
 * [George Wilson - Contravariant Functors: The Other Side of the Coin](https://youtu.be/IJ_bVVsQhvc)
 * [Composing predicates #Haskell](https://dev.to/gillchristian/composing-predicates-30jb)

 */

print("🥳🥳🥳")
