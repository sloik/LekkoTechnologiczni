//: [Previous](@previous)

import UIKit

NSSetUncaughtExceptionHandler{print("💥 Exception thrown: \($0)")}

/*:
 # `Kowariancja` oraz `Kontrawariancja`
 
 Temat `kontrawariancji` oraz `kowariancji` najczęściej można spotkać w programowaniu obiektowym przy dziedziczeniu.
 
 > `Covariance` (Kowariancja) - bardziej precyzyjny typ możemy zamienić na ogólny (more generic).
 
 W Swift wartość zwracana z funkcji _jest kowarjancją_ (tu tłumaczenie z angielskiego na naszed może nie być takie dokładne).
 
 Aby to pokazać stworzę prostą hierarchią klas. Ważne jest aby zwrócić uwagę na _kierunek dziedziczenia_ (w którą stronę idą strzałki).
 
 ```
 ┌──────────────────────┐
 │         Base         │
 └──────────────────────┘
            ↑
 ┌──────────────────────┐
 │         Mid          │
 └──────────────────────┘
            ↑
 ┌──────────────────────┐
 │        Final         │
 └──────────────────────┘
 ```
 
 */

class Base{}

class Mid: Base {
    var wow: String { "wow" }
}

final class Final: Mid {
    func wof() { print("wof") }
}

/*:
 Klasa `Base` jest **najbardziej ogólna**. Klasa `Final` jest **najbardziej szczególna** (wyspecjalizowana). Mówiąc to samo innymi słowami mogę powiedzieć, że _im wyżej klasa jest w hierarchii tym stanowi bardziej ogólny pomysł a im niżej tym bardziej szczegółowy_.
 
 Utworzę instancje z każdego typu. Aby potem kompilator nie zastosował jakiejś własnej magii zawszę będę definiować typ zmiennych. Swift ma tak, że wybiera taką kombinację typów, która się skompiluje a nie koniecznie o jaką chodzi w przykładach.
 */

let  base: Base  = Base()
let   mid: Mid   = Mid()
let final: Final = Final()

/*:
 Dla przypomnienia: **covariance** jest w sytuacji, gdy zwracany **typ możemy zamienić na bardziej ogólny**. W przypadku programowania obiektowego, gdy możemy zwrócić ten typ lub dziedziczący po nim (bardziej szczegółowy).
 
 Jak wspomniałem wyżej funkcje w Swift są _covariant_.
 
 Napiszę trzy funkcje. Każda z nich będzie zwracać wartość typu `Mid`. Jednak w implementacji stworzę 3 różne instancje (Base, Mid, Final). Zobaczmy co się stanie:
 */

//
// Cannot convert return expression of type 'Base' to return type 'Mid'
//
// Insert ' as! Mid' [Fix It]
//
//func produceMidBase() -> Mid { Base() }

/*:
 Funkcja `produceMidBase` się nie kompiluje. W sumie nikogo to nie dziwi kto chociaż trochę programował obiektowo. W tej konkretnej sytuacji mówimy, że chcemy _typ bardziej szczegółowy_ (mniej ogólny, bardziej wyspecjalizowany) niż dostarczamy.
 
 Koleje dwie funkcje już się kompilują:
 */

func produceMidMid() -> Mid { Mid()   }

/*:
 Funkcja `produceMidBase` zwraca instancje dokładnie tego samego typu co w deklaracji. Więc z punktu widzenia naszego tematu nic ciekawego się nie dzieje.
 */

func produceMidFinal() -> Mid { Final() }

/*:
 Funkcja `produceMidFinal` _pod spodem_ tworzy instancje klasy `Final` ale na wyjściu wiemy tylko tyle, że jest to instancja typu `Mid`. I tu mamy ten przypadek gdzie **zwracany typ został skonwertowany na bardziej ogólny**. Wszystko co charakteryzowało instancje `Final` zostało _zapomniane_ do _poziomu_ `Mid`.
 
 Słownictwo niestety nie pomaga. Zachęcam do rzucenia okiem jeszcze raz na hierarchię klas. Należy też pamiętać, że im coś jest wyżej to jest bardziej _ogólne_. Oczywiście w czasie życia aplikacji (w pamięci komputera) to jest pełno prawna instancja klasy `Final`. Jednak na poziomie kompilacji wiemy o tej instancji tylko tyle, że _jest_ `Mid`.
 
 Grzebiąc dalej w rozważaniach dotrzemy do zasad z akronimu SOLID a konkretnie mam na myśli L czyli _zasada podstawienia Liskov_. Chodzi o to, że powinniśmy zawsze móc podmienić instancję jakiejś klasy na jej podtyp. Dzięki temu jeżeli jakiś algorytm wymaga "mniej wiedzy" i działa z instancją typu `Mid`. To możemy dać mu taki `Final` przebrany za `Mid` i program **powinien działać tak samo** (a już na pewno nie powinien crash-ować).
 
 Z podwórka iOS to funkcja mogłaby zwracać jakiś `UIViewController` lub po prostu jakiś `UIView` zamiast bardziej konkretnych widoków lub view controllerów. Dzięki temu można stawiać _tamy_ między modułami/klasami aby jak najmniej wiedziały o sobie. To pozwala je wymienić w przyszłości na inne, jeżeli zajdzie taka potrzeba.
 
 Szybki przykład...
 */

run {
    var expectingMid: Mid
    
    expectingMid = produceMidMid()
    expectingMid = produceMidFinal()
    
    
    //
    // Cannot convert value of type 'Mid' to specified type 'Final'
    //
//    var _: Final = produceMidFinal() //
    
    expectingMid // just to silence a warning
}

/*:

 W pierwszej części bez problemu do zmiennej `expectingMid` możemy przypisać zwracane instancje z obu funkcji. Mimo, że jedna z nich jest bardziej szczegółowa. Tak jak to wałkujemy od jakiegoś czasu, ta szczegółowość została _zapomniana_.
 
 Niestety gdy chcemy utworzyć referencje do klasy typu `Final` i użyć metody, która tworzy instancje tego typu i ją zwraca, to nie możemy tego zrobić. Kompilator _zapomina_, że tam pod spodem jest właściwa instancja i nie pozwala na kompilacje z odpowiednim błędem.
 
 Ok to mamy za sobą czas na drugą stronę medalu...
 
 # Contravariance - Kontrawariancja
 
 Teraz idziemy w drugą stronę. Kowariancja mówiła nam _co może być zwracane_ z funkcji. Kontrawariancja mówi jakiego typu mogą być parametry wejściowe do funkcji.
 
 > **Kontrawariancja jest w sytuacji gdy przekazujemy dokładnie ten typ co argument LUB bardziej szczegółowy (dziedziczący)**.
 
 W Swift parametry do funkcji są **kontrawariancyjne**.
 
 Warto zwrócić uwagę, że dla **kowariancji** poruszamy się _w górę_ drzewa dziedziczenia (zwracamy bardziej ogólne typy). Natomiast dla **kontrawariancji** schodzimy w dół (przyjmujemy bardziej szczegółowe).
 
 Trywialny przykład z funkcją, która oczekuje na argument typu `Mid`:
 */

func consumeMid(_ m: Mid) {}

//
// Cannot convert value of type 'Base' to expected argument type 'Mid'
//
// consumeMid(base)

/*:
 Przekazanie bardziej ogólnego typu nie mogło się udać. Na chłopski rozum _robi to sens_. Skoro funkcja określa typ wejściowy jako taki to pewnie **potrzebuje** funkcjonalności tego typu. Algorytm w ciele (u nas nie występuje) zapewne odwołuje się do właściwości oraz funkcjonalności tego typu.
 */

consumeMid(mid)
consumeMid(final)

/*:
 Do funkcji `consumeMid` przekazałem instancje typu `Final`, która dziedziczy po `Mid`. Jest typem _bardziej szczegółowym_. Tu kompilator ponownie zapomina o tym co jest bardziej szczegółowe. Dzięki temu można przekazywać do takich funkcji instancje typów bardziej szczegółowych (bardziej wyspecjalizowanych, bardziej konkretnych).
 
 # Skąd takie nazewnictwo
 
 Tutaj trochę _szyję_ i raczej jest to _sposób na zapamiętanie_ o co chodzi. Na pewno ktoś z bardziej językoznawczym zacięciem/wiedzą mógłby powiedzieć więcej
 
 Przedrostek _ko_ sugeruje wykonywanie czegoś wspólnie/razem z czymś innym. Przedrostek _kontra_ oznacza bycie przeciw czemuś. Teraz tylko musimy odszukać _to coś_ ;)
 
 Rzut oka na diagram dziedziczenia:
 ```
 ┌──────────────────────┐
 │         Base         │
 └──────────────────────┘
            ↑
 ┌──────────────────────┐
 │         Mid          │
 └──────────────────────┘
            ↑
 ┌──────────────────────┐
 │        Final         │
 └──────────────────────┘
 ```
 
 `Final` dziedziczy po `Mid`. `Mid` dziedziczy po `Base`. Relacja idzie od dołu do góry co symbolizuje strzałka `↑`.
 
 **Kowariancja idzie w tą samą stronę / zgodnie / razem z relacją dziedziczenia**
 
 Z funkcji zwracającej `Mid` można zwrócić konkretną instancję `Final`. Czyli gdy mamy `Final` ukrywamy to za interface-em `Mid`. Zwracamy bardziej ogólny typ, który jest w tym samym kierunku co hierarchia dziedziczenia.
 
 **Kontrawariancja idzie w przeciwną stronę**.
 
 Dla funkcji przyjmującej jako argument typ `Mid` możemy przekazać instancję typu `Final` (bardziej szczegółowy typ niż wymagany), która idzie w przeciwną stronę niż hierarchia dziedziczenia.
 
 Przyznam, że ten pierdolnik nazewniczy wcale nie pomaga w zrozumieniu tego tematu. Nie dość, że oba wyrazy brzmią bardzo podobnie to jeszcze w moim odczuciu wydają się bardziej sztuczne (chociaż wcale takie nie są). Do tego temat wariancji(?) występuje w innych kontekstach (np. fizyka, statystyka) i tam może mieć inne znaczenie, które wcale tak łatwo się nie przenosi do programowania (nie wiem, nie jestem statystykiem ani fizykiem).
 
 Po prostu daj sobie trochę czasu i za jakiś czas wróć do tego tematu jeszcze raz i mam nadzieję, że _zaskoczy_.
 
---
 # Generyki
 
 Było gęsto ale to nie jest koniec tej historii. Czas wprowadzić do gry generyki.
 
 W Swift mamy kilka typów generycznych np. Array, Optional i Result. Nie da się utworzyć instancji tych typów bez podania dokładnego typu dla parametru generycznego.
 
 Rzućmy okiem jak wygląda _kowariancja_ i _kontrawariancja_ gdy pracujemy z Optionalem.
 
 Dla przypomnienia Optional to zwykły enum z generykiem.
 
 ```swift
 enum Optional<Wrapped> {
     case some(Wrapped)
     case none
 }
 ```
 
 Aby kompilator nie płatał żadnego figla to zdefiniuję odpowiednie instancje i ich będę używać dalej.
 */

let optionalBase :  Base? = .some(base )
let optionalMid  :   Mid? = .some(mid  )
let optionalFinal: Final? = .some(final)

/*:
 Zaczniemy od _kowariancji_ dla Optional.
 */

//
// Cannot convert return expression of type 'Base?' to return type 'Mid?'
//
//func produceOptionalMidFromBase() -> Mid? { optionalBase }

/*:
 Tak jak poprzednio widać, że nie jesteśmy z typu ogólnego `Base` _wyczarować_ instancji typu `Mid`.
 */

func produceOptionalMidFromMid()   -> Mid? { optionalMid   }
func produceOptionalMidFromFinal() -> Mid? { optionalFinal }

/*:
 Relacja została zachowana. Podobnie jak `Final` jest typem bardziej szczegółowym niż `Mid`, tak `Optional<Final>` jest typem bardziej szczegółowym niż `Optional<Mid>`. Czyli generyk w optionalu dla tych funkcji jest kowariancyjny. Aby to lepiej oddać można umownie zapisać to ze znakiem `+` czyli `Optional<+Wrapped>` lub po prostu `+Wrapped`.
 
 I faktycznie skoro śliwka jest owocem to torba śliwek jest torbą owoców. W tym przypadku _torbą_ jest optional a śliwką typ `Wrapped`.

 Rzućmy okiem na jeszcze jeden typ z tym samym zachowaniem. Ukochaną tablicę (patrzymy na typy a nie na zawartość więc pusta tablica nada się tak samo):
 */

let  arrayBase: [  Base] = []
let   arrayMid: [   Mid] = []
let arrayFinal: [ Final] = []

//
// Cannot convert return expression of type '[Base]' to return type '[Mid]'
//
//func produceArrayMidFromBase() -> [Mid] { arrayBase }

func    produceArrayMidFromMid() -> [Mid] { arrayMid   }
func  produceArrayMidFromFinal() -> [Mid] { arrayFinal }

/*:
 Array w Swift jest typem generyczny z parametrem typu nazwanym `Element` – ten parametr **jest kowariancyjny**. Trzymając się poprzedniego zapisu można napisać tak: `[+Wrapped]` lub `Array<+Wrapped>`.
 
 Możemy zwrócić typ bardziej ogólny Array<Mid> gdy mamy instancję Array<Final> **dokładnie tak samo** gdy możemy zwrócić typ `Final` z funkcji zwracającej `Mid`.
 
 # Druga strona lustra
 
 Czas rzucić okiem na _kontrawariancje_.
 */

func consumeOptionalMid(_ b: Mid?) {}

//
// Cannot convert value of type 'Base?' to expected argument type 'Mid?'
//
//consumeOptionalMid(optionalBase)

/*:
 Mogłem sobie już darować ten podstawowy przypadek, ale bardzo mi zależy na pokazaniu, że niczego nie ukrywam.
 */

consumeOptionalMid(optionalMid)
consumeOptionalMid(optionalFinal)

/*:
 Tu zachowanie dokładnie takie samo jak wcześniej. Mogę przekazać instancję typu `Final` do funkcji spodziewającej się instancji `Mid`. Ten typ idzie _w drugą stronę_ hierarchii dziedziczenia a więc mówimy o **kontrawariancji**.
 
 Dla _kompletu_ zróbmy to samo _ćwiczenie_ dla tablic:
 */

func consumeArrayMid(_ b: [Mid]) {}

//
// Cannot convert value of type '[Base]' to expected argument type '[Mid]'
//
//consumeArrayMid( arrayBase )

consumeArrayMid( arrayMid )
consumeArrayMid( arrayFinal )


/*:
 Tablica i Optional przy tych funkcjach są `contravariant`. Funkcja spodziewa się bardziej ogólnego typu ale **może przyjąć bardziej szczegółowy** i _zapomnieć_ troszeczkę o tym typie tak aby z nim pracować.
 
 Inny przykład. Funkcja przyjmująca instancję typu `Animal` może przyjąć instancję typu `Dog` (pies jest zwierzęciem).
 
 # Własne Kontenery
 
 W przykładach wyżej widać, że typy _kontenerowe_ (owijające wartość w kontekst) też mają tą właściwość.
 
 Optional<Mid> **jest** Optional<Base>
    Array<Mid> **jest**    Array<Base>
 
 Dokładnie tak samo jak `Mid` **jest** `Base`.
 
 **Niestety takie zachowanie nie jest dostępne dla typów zdefiniowanych przez nas**.
 
 Swift jest jeszcze młodym językiem i takie zachowania są na dzień dzisiejszy możliwe tylko dla kontenerów zdefiniowanych w bibliotece standardowej.
 
 Zobaczmy co się stanie gdy napiszemy własną wersję `Optional`a:
 */

enum MyOptional<T> {
    case mysome(T)
    case none
}

/*:
 Nazwy case-ów są trochę inne aby nie było wątpliwości, że używam metod na właśnie zdefiniowanym typie.
 
 Implementacja jest **identyczna** jak w bibliotece standardowej. Jedyne co jest inne to, że Swift nie ma specjalnej wiedzy na temat tego typu.
 
 Zobaczmy co się stanie jak będę chciał _skonsumować_ instancję takiego typu:
 */

func consumeMyOptionalMid(_ myOptional: MyOptional<Mid>) {}

/*:
 Kształt powinien już być znajomy. Funkcja powinna przyjąć `MyOptional<Mid>`. Wcześniejsze funkcje przyjmowały `Array<Mid>`, `Optional<Mid>` lub po prostu `Mid`.
 */

let myOptionalBase  : MyOptional<Base>  = .mysome(base )
let myOptionalMid   : MyOptional<Mid>   = .mysome(mid  )
let myOptionalFinal : MyOptional<Final> = .mysome(final)

/*:
 Ponownie aby kompilator sobie niczego sam nie wykombinował jawnie deklaruje instancje jakich będę używać. I po raz kolejny ich _zawartość_ nie jest istotna (mógłbym użyć tu case none). Chodzi o typ!
 */


//Cannot convert value of type 'MyOptional<Base>' to expected argument type 'MyOptional<Mid>'
//consumeMyOptionalMid(myOptionalBase)

consumeMyOptionalMid(myOptionalMid)

// Cannot convert value of type 'MyOptional<Final>' to expected argument type 'MyOptional<Mid>'
//consumeMyOptionalMid(myOptionalFinal)

/*:
 Ten kod się nie skompiluje. Mimo, że implementacja `MyOptional` jest skopiowana z oryginalnego Optional-a to jednak kompilator traktuje go inaczej!
 
 Co więcej jedyna opcja kiedy możemy tego używać to w sytuacji kiedy dostarczamy instancje **dokładnie tego typu co jest określony w parametrze funkcji!**
 
 ## Jeszcze jedna szansa
 
 Może to wina tego, że użyliśmy enum-a? Więc stwórzmy własny _kontener_ w postaci _jednoelementowej tablicy_.
 */

struct OneElementArray<T>: ExpressibleByArrayLiteral {
    let element: T
    
    init(arrayLiteral elements: T...) {
        element = elements.first!
    }
}

/*:
 `OneElementArray` implementuje `ExpressibleByArrayLiteral`. Więc do stworzenia instancji będzie można użyć literału tablicy. Ponieważ to są cele _szkoleniowe_ to wyciągnę tylko pierwszy element z literału i przypisze do stałej `element`.
 */

extension OneElementArray: Collection {
    
    typealias Index = Int
    
    var startIndex: Index { 0 }
    var endIndex: Index { 1 }
    
    subscript(index: Index) -> T {
        get { element }
    }
    
    func index(after i: Index) -> Index {
        i + 1
    }
}

/*:
 Aby _iluzja_ była pełna nawet zrobiłem z tego kolekcje. Jest to zbędny krok ale chcę _udać_ tablicę tak bardzo jak się da a nie jest to zbyt upierdliwe.
 */

let oneElementBase  : OneElementArray<Base>  = [base]
let oneElementMid   : OneElementArray<Mid>   = [mid]
let oneElementFinal : OneElementArray<Final> = [final]

run("🐑 one element collection") {
    for element in oneElementBase {
        print(element)
    }
}

/*:
 Scena jest ustawiona. Czas na napisanie konsumującej `OneElementArray<Mid>` funkcji tak jak wcześniej:
 */

func consumeOneElementArrayMid(_ b: OneElementArray<Mid>) {}

// Cannot convert value of type 'OneElementArray<Base>' to expected argument type 'OneElementArray<Mid>'
//consumeOneElementArrayMid( oneElementBase )

consumeOneElementArrayMid( oneElementMid )

// Cannot convert value of type 'OneElementArray<Final>' to expected argument type 'OneElementArray<Mid>'
//consumeOneElementArrayMid( oneElementFinal )

/*:
 Dokładnie ta sama historia dla _jednoelementowej tablicy_!.
 
 **Napisane przez nas własne typy NIE SĄ kontrawariatne**. Musimy przekazać **dokładnie** ten typ jako argument inaczej kod się nie skompiluje.
 
## Ok więc może są **kowariantne**?

 Dla przypomnienia wyżej pokazaliśmy, że Optional i Array takie są. Co z naszymi typami?
 */

//
// Cannot convert return expression of type 'MyOptional<Base>' to return type 'MyOptional<Mid>'
//
//func produceMidFromMyOptionalBase() -> MyOptional<Mid> { myOptionalBase }

func produceMidFromMyOptionalMid()  -> MyOptional<Mid> { myOptionalMid }

//
// Cannot convert return expression of type 'MyOptional<Final>' to return type 'MyOptional<Mid>'
//
//func produceMidFromMyOptionalFinal()  -> MyOptional<Mid> { myOptionalFinal }

/*:
 I jeszcze super jedno elementowa (to jest po polsku?) tablica:
 */

//
// Cannot convert return expression of type 'OneElementArray<Base>' to return type 'OneElementArray<Mid>'
//
//func produceMidFromOneElementBase() -> OneElementArray<Mid> { oneElementBase }

func produceMidFromOneElementMid () -> OneElementArray<Mid> { oneElementMid  }

//
// Cannot convert return expression of type 'OneElementArray<Final>' to return type 'OneElementArray<Mid>'
//
//func produceMidFromOneElementFinal () -> OneElementArray<Mid> { oneElementFinal  }

/*:
 # Jeszcze jeden rodzaj wariancji...
 
 Mam nadzieję że widać iż nie mamy to do czynienia ani z _kowariancja_ ani z _kontrawariancją_.
 
 **Własne (nie zdefiniowane w bibliotece standardowej) typy generyczne w Swift są INWARIANCYJNE**.
 
 # Wariancja Funkcji
 
 Wszystko co powiedziałem wcześniej było po to aby można było rozmawiać o tym temacie. Ponieważ okazuje się, że można spojrzeć na typy funkcyjne i zastanowić się czy dany typ w tej funkcji jest na pozycji _kowariancji_ czy _kontrawariancji_.
 
 ## Po co?
 
 Okazuje się, że jeżeli jakiś typ w funkcji jest na pozycji _kowariancji_ to **najprawdopodobniej** można na nim zdefiniować funkcję `map`.
 
 Natomiast jeżeli jest na pozycji _kontrawariancji_ to można zdefiniować funkcję `comap` (contra map). To otwiera drzwi do _jeszcze jednego rodzaju kompozycji_. Takiej z której za często się nie korzysta ale równie użytecznej.
 
 Zastosowanie w praktyce `comap` można zobaczyć w [📸 SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) . Tam jest "ukryta" pod nazwą `pullback` (ta operacja jest uogólnieniem comap-y).
 
 ## Wariancja Funkcji
 */

func m2m(_ m: Mid) -> Mid { m }

// (Mid) -> Mid     =>  M -> M
type(of: m2m)

/*:
 Typ funkcji `f` to : `(Mid) -> Mid`. Aby nieco zagęścić zapis dalej będę używać notacji `M -> M`.
 
 Dopisze kolejne typy funkcji:
 */

var mid2mid: (Mid)   -> Mid = m2m
//                   ↓
let fin2mid: (Final) -> Mid = mid2mid

//
// Cannot convert value of type '(Mid) -> Mid' to specified type '(Base) -> Mid'
//
//let bas2mid: (Base) -> Mid = mid2mid

/*:
 Widać, że typ `M->M` możemy przypisać do `F->M`. Możemy nawet _narysować_ hierarchie "dziedziczenia" dla takich typów funkcji.
 ```
 ┌──────────────────────┐
 │   (Final) -> Mid     │
 └──────────────────────┘
             ↑
 ┌──────────────────────┐
 │     (Mid) -> Mid     │
 └──────────────────────┘
 ```
 
 _Typ `M->M jest podtypem F->M`_. W tym diagramie `Final` jest nad `Mid`. W przeciwną stronę niż dziedziczenie a więc **kontrawariancja**.
 
 ## B-ee
 
 Co z pozycją wyjściową?
 */

let mid2fin: (Mid) -> Final = { _ in final }
var mid2bas: (Mid) -> Base

mid2bas = mid2mid // M->M dziedziczy po M->B
mid2bas = mid2fin // M->F dziedziczy po M->B
mid2mid = mid2fin // M->F dziedziczy po M->M

//
// Cannot convert value of type '(Mid) -> Mid' to specified type '(Mid) -> Final'
//
//let mid2final: (Mid) -> Final = mid2mid

/*:
 Wygląda na to, że możemy przypisać funkcje `mid2mid` do funkcji, która zwraca _bardziej ogólny_ typ. Czyli mamy tu do czynienia z **kowariancją**.
 
 Zbierając wszystko do 💩 mamy taki krajobraz:
 ```
 ┌──────────────────────┐
 │     (Mid) -> Base    │
 └──────────────────────┘
             ↑
 ┌──────────────────────┐
 │     (Mid) -> Mid     │
 └──────────────────────┘
             ↑
 ┌──────────────────────┐
 │     (Mid) -> Final   │
 └──────────────────────┘
 ```
 Jak to czytać? Normalnie, jak hierarchię dziedziczenia.
 
 Typ `M->B` jest supertypem dla typu `M->M`. Lub inaczej, typ `M->M` dziedziczy po typie `M->B` itd. I jak spojrzymy na prawą stronę za `->` jest to w zgodzie z hierarchią dziedziczenia.
 
 ### Jeszcze inaczej
 
 ** Jeżeli `M` jest podtypem `B` to funkcję `B->F` są podtypem `M->F` oraz funkcję F->M są podtypem F->B**
 
 Narysuje to jeszcze raz:
 ```
 ┌──────────────────────┐
 │          B           │
 └──────────────────────┘
            ↑
 ┌──────────────────────┐
 │          M           │
 └──────────────────────┘
 ```
 
 _M jest podtypem B_
 
 ```
 ┌──────────────────────┐
 │       (M) -> F       │
 └──────────────────────┘
             ↑
 ┌──────────────────────┐
 │       (B) -> F       │
 └──────────────────────┘
 ```
 
 _B->F jest podtypem M->F_.  Relacja typów tych funkcji jest **odwrócona** z hierarchią dziedziczenia! **KONTRAwariancja**.
 
 ```
 ┌──────────────────────┐
 │       (F) -> B       │
 └──────────────────────┘
             ↑
 ┌──────────────────────┐
 │       (F) -> M       │
 └──────────────────────┘
 ```
 
 _F->M są podtypem F->B_.  Relacja typów tych funkcji jest **zgodna** z hierarchią dziedziczenia! **KOwariancja**

 Zobaczmy to w kodzie:
 */

let fF2F: (Final) -> Final = { _ in final }
//                ↓
let fM2F: (Mid)   -> Final = { _ in final }
//                ↓
let fB2F: (Base)  -> Final = { _ in final }

run {
    var baseFunctionType: (Mid) -> Final = fM2F
    
    // Przypisuje ten sam typ, działa.
    baseFunctionType = fM2F
    
    // Przypisuję typ dziedziczący (będący niżej w hierarchii)
    baseFunctionType = fB2F
    
    // Na tej samej zasadzie jak do zmiennej mogę przypisać typ bardziej szczegółowy.
    var _: Mid = Final()
    
    //
    // Cannot assign value of type '(Final) -> Final' to type '(Mid) -> Final'
    //
//    baseFunctionType = fF2F
    
    // Tak samo nie mogę
//     var _: Mid = Base()
}

let fF2B: (Final) -> Base  = { _ in base  }
//                ↑
let fF2M: (Final) -> Mid   = { _ in mid   }
//                ↑
let   _ : (Final) -> Final = { _ in final }

run {
    var baseFunctionType: (Final) -> Base
    
    // Przypisuje ten sam typ, działa.
    baseFunctionType = fF2B
    
    // Przypisuję typ dziedziczący (będący niżej w hierarchii)
    baseFunctionType = fF2M
    baseFunctionType = fF2F
    
    // Na tej samej zasadzie jak do zmiennej mogę przypisać typ bardziej szczegółowy.
    var _: Base = final
    var _: Mid = final
}

/*:
 Określanie czy jakiś typ jest na pozycji kowariatnej czy kontrawariatnej jest nieco kłopotliwe gołym okiem. Natomiast można zastosować pewien trick.
 
 Wszystkie parametry będące po lewej stronie `->` będziemy traktować jako posiadające znak `-` minus (można o nich pomyśleć jak o _zjadających_ wartości).
 
 Wszystkie parametry będące po prawej stronie `->` będziemy traktować jako posiadające znak `+` plus (można o nich pomyśleć jak o _wytwarzających_ wartości).
 
 A więc funkcja:
 */

func someFunction<A,B>(_ a: A) -> B { fatalError("I'm here for the type!") }

/*:
 Bardziej ogólnie zapisana jako:
 
 ```
(A) -> B
 ```
 
 będzie miała w tym zapisie postać:

 ```
(A) -> B
 -     +
 ```
 
 Dla bardziej skomplikowanych funkcji używamy _nawiasów_:
 
 ```
(A) -> (B) -> C
      ( -     +)
 -         +
 ```
 
 A => -
 
 B => + * - = -
 
 C => + * + = +
 
 A więc wiemy, że typ `A` jest kontrawariantny (-), typ `B` również (-) a typ `C` jest kowariantny. Przypominam, jeżeli coś jest na pozycji `+` to pewnie można do tego typu dopisać funkcje `map` (taka funkcje map, która jest funktorem i o której już wspominaliśmy trochę wcześniej to nie będziemy się powtarzać). Jeżeli na `-` to można dopisać funkcje `contra map`.

# Podsumowanie
 
 Temat można jeszcze ciągnąć dalej, ale na ten moment powiemy sobie dość.
 
 Jeżeli nie zeżre to zachęcam wrócić do temu za jakiś czas. Jest to bardzo abstrakcyjne i w pracy, która polega na przesuwaniu labelek nie jest za bardzo do szczęścia potrzebne. Przydaje się w momencie kiedy zaczyna się myślenie "co z czym mogę połączyć tak, że nie zepsuje programu" :)
 
 # Linki & Notatki
 
 * [Lekko Technologiczny odcinek wprowadzający w funkcję `map`](https://www.youtube.com/watch?v=rhNHaLb1zXQ&list=PLk_5PV9LrXp-R6TM86MxqlihQSu_ZIhUk&index=9)
 * [O kowariancji i kontrawariancji by Paweł Lipski](http://www.deltami.edu.pl/temat/informatyka/2014/08/28/1409delta-programowanie.pdf)
 * [PointFree odcinek o kontrawariancji](https://www.pointfree.co/episodes/ep14-contravariance)
 * [Swift Generics Manifesto](https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md)
 * [Generics in Swift](https://github.com/apple/swift/blob/master/docs/Generics.rst)
 * [The Functor Family: Contravariant](https://cvlad.info/contravariant/)
 * [TOUR OF SCALA VARIANCES](https://docs.scala-lang.org/tour/variances.html)
 * [Kontrawariancja i kowariancja w języku C#](http://kurs.aspnetmvc.pl/Csharp/kontawariancja_kowariancja)
 * [COVARIANCE AND CONTRAVARIANCE BY MICHAEL SNOYMAN](https://www.fpcomplete.com/blog/2016/11/covariance-contravariance/)
 * [Kowariancji i kontrawariancja (informatyka)](https://pl.qwe.wiki/wiki/Covariance_and_contravariance_(computer_science))
 * [Covariance and Contravariance in Swift](https://medium.com/@aunnnn/covariance-and-contravariance-in-swift-32f3be8610b9)
 * [Generic types—covariance/contravariance](https://forums.swift.org/t/generic-types-covariance-contravariance/4680)
 * [The Systemics of the Liskov Substitution Principle - Romeu Moura - DDD Europe 2018](https://youtu.be/tNpW-V2HXJ0)
 */
 


print("🤨")
