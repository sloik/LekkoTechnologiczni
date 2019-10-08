import Foundation

//: # Funkcje: jeden na jednego
/*:
Funkcje grupują pod wspulną nazwą _niezależne_ kawałki kodu. Aby zdefiniować funkcję zaczynama od słowa kluczowego `func` po którym następuje nazwa funkcji. Następnie w nawisach list argumentów po której występuje `->` i zwracany `typ`/wartość.
 */

func printQuote() -> Void {
    print(#function + " was called")
}

/*:
Aby wywołać funkcję musimy użyć jej nazwy i przekazać wymagane argumenty w nawiasach `()`.
 */

run("call function") {
    printQuote()
}

/*:
Funkcje mogą przyjmować argumenty i zwracać wartości.
 */

func countLength(of inString: String) -> Int {
    return inString.count
}

run {
    let someString = "War is hell!"

    let lenthOfSomeString = countLength(of: someString)
    type(of: lenthOfSomeString)
}

/*:
Każda funkcja posiada swój własny `typ`. Czyli swego rodzaju _kontrakt_ z jakimi wartościami pracuje i jakie zwraca.
 */
func increment(_ i: Int) -> Int {
    return i + 1
}

func square(_ i: Int) -> Int {
    return i * i
}

run("Function has a type") {
    type(of: printQuote)
    type(of: countLength(of:))
    type(of: increment)
    type(of: square)

    assertTrue(type(of: increment) == type(of: square))
    assertTrue(type(of: increment) == type(of: countLength(of:)))
}

/*:
Swift pozwala nam traktować funkcje jak _obiekty_.
 */

run {
    let someInt = 42
    var someFunction: (Int) -> Int = increment

    assertEqual(
           increment(someInt),
        someFunction(someInt)
    )

/*:
Ponieważ nasza zmienna trzyma referencje do funkcji o określonym typie to możemy teraz do niej przypisać inna funkcje ale o takim samym typie.
 */

    someFunction = square
    assertEqual(
              square(someInt),
        someFunction(someInt)
    )
}

/*:
Można też stworzyć funkcje _z doskoku_.
 */

let decrement = { (i: Int) in i - 1 }

run("Call decrement") {
    print(decrement(42))
}

/*:
Gsybyśmy nie uzyli `let decrement` to nie mielibyśmy nazwy po której możemy się odwołać do tak napisanej funkcji. O takiej funkcju mówimy, że jest `anonimowa`.

 Na pierwszy rzut oka taka funkcjonalność może się wydawać mało użyteczna. Jednak gdy połączymy to z faktem, że funkcje możemy traktować jako obiekty to okazuje się, że można przekazywać funkcje do innych funkcji.

 Warto też zwrócić uwagę, że przy użyciu skladni funkcji anonimowej można ją zdefiniować w miejsce parametru. Odwołując się do przykładu z `decrement`. Nie trzeba było wcześniej deklarować stałej/zmiennej która by potem była _włożona_ jako argument. Wartość `42` została przekazana bezpośrednio.

 W podejściu Obiektowym funkcje są powiązane z danymi i mówimy o nich _metody_. W prakryce obie nazwy są uzywane prktycznie zamiennie.
 */

struct BoxOfInts {
    let someInt: Int

    func intInsideTheBox() -> Int { someInt }
}

run {
    let boxFor42 = BoxOfInts(someInt: 42)

    boxFor42.intInsideTheBox()
}

/*:
Funkcj można też definiować na typie a nie tylko na instancji tego typu.
 */

extension BoxOfInts {
    static func makeMeABox(for inInt: Int) -> BoxOfInts {
        return BoxOfInts(someInt: inInt)
    }
}

run {
    let boxFor4 = BoxOfInts.makeMeABox(for: 4)
    boxFor4.intInsideTheBox()
}

/*:
W praktyce można powiedzieć, że każda funkcja tworząca instancje typu (tzw. init-ializer) jest globalnie dostępną, statyczną (wołaną na typie) funkcją.
 */

run {
    let boxInit = BoxOfInts.init(someInt:)
    type(of: boxInit)

    let boxForTwo = boxInit(2)
    boxForTwo.intInsideTheBox()

/*:
To samo możemy zobaczyć dla typów z biblioteki standardowej.
*/

    let stringInit       : ()       -> String = String.init
    let intFromStringInit: (String) -> Int?   = Int.init

    let string = stringInit()
    type(of: string)
    string.count
    string.isEmpty

    let intFromString = intFromStringInit("3")
    type(of: intFromString)
    intFromString
}

/*:
 Tak na prawdę ;) wywołanie metody na obiekcie to cukier składniowy na wywołanie metody statycznej (zdefiniowanej na typie) i przekazanie do niej instancji (danych).
 */

run {
    let instance = BoxOfInts(someInt: 69)

     BoxOfInts.intInsideTheBox

/*:
Sprawdzmy typ

![boi](boi-intInside.png "Kompilatorowa podpowiadaczka")

`BoxOfInts.intInsideTheBox` jest to funkcja, która w parametrze `self` oczekuje instancji `BoxOfInt` i zwraca funkcję typu `() -> Int`
 */
    let methodCreator: (BoxOfInts) -> () -> Int = BoxOfInts.intInsideTheBox

/*:
Dostarczmy jawnie naszą instancje do metody:
 */
    let intInsideForInstance: () -> Int = BoxOfInts.intInsideTheBox(instance)
    let intInsideFromCreator: () -> Int = methodCreator(instance)

/*:
Podomnie możemy złapać referencje/wskazanie na metodę bezpośrednio z instancji.
*/
    let methodFromInstance: () -> Int = instance.intInsideTheBox

/*:
Czas sprawdzić czy wszystko zwraca tą samą wartość:
*/
    assertAllSame(
        instance.intInsideTheBox(),
        intInsideForInstance(),
        intInsideFromCreator(),
        methodFromInstance(),
        69
    )

/*:
Dzięki `ukryciu` tych metod mamy `obiektową abstrakcje` przy pomocy której możemy pisać programy. Dzieje się tak ponieważ nie potrzebujemy duplikować kodu każdej metody dla każdej instancji ;) Nie miało by to najmniejszego sensu ;) Implementacja kodu jest reużywana na różnych danych i o to w tym chodzi.

Warto wiedzieć, że ten mechanizm tak działa pod spodem i mam nadzieję teraz jest jaśniejsze chociaż to skąd się bierze słowo kluczowe `self`.
*/
}

/*:
Funkcje mogą _żyć_ jako globalnie dostępne. W praktyce jest bardzo dużo funkcji, które możemy zawołać _z powietrza_. Jeszcze jak doliczymy do tego wszystkie dostęne init-y obiektów to okaże się, że jest tego bardzo dużo.

 Możemy definiować funkcje statycznie (na typie). W tym wypadku typ tworzy nam `namespace` i ogranicza widoczność danej funkcji do tego typu. Bardzo łatwo jest spokać w kodzie takiego zwierza, który nie przechowuje żadnych danych a służy jako agregat funkcji.

 Funkcje też mogą być zdefiniowane na instancji danego typu. Jest to typowe podejście dla obiektowego stylu programowaia. Chodzi o to aby dane i zachowania powiązane z tymi danymi były zdefiniowane w jednym miejscu, jak najbliżej siebie.

 Ostatni sposób w jaki można zdefinować funkcje to bloki/closurs/lambdy. Wszystkie te trzy wyrazy opisują ten sam pomysł. Definjujemy ciało funkcji bez nadawania jej nazwy. Wszelakie API które w nazwie mają `completionBlock` używają najczęściej tej formy.

 Jak widać funkcje są wszędzie. Żyją w globalnej (wolnej) przestrzenii czy też zdefiniowane na konkretnym typie do którego mamy dostęp globalnie. Nie trzeba ich się bać (a szczególnie tego, że są globalnie dostępne) i traktować jak mityczne stwory do ubicia. Są bardzo użyteczne i mają ciekawe właściwości, które postaramy się głębiej zbadać.
*/

