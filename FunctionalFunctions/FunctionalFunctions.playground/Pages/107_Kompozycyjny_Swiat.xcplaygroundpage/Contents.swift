//: [Previous](@previous)

import Foundation
import PlaygroundSupport

/*:
 # Kompozycyjny Świat
 
 > - _Jak zabić niebieskiego słonia?_
 > - _To proste! Strzelbą na niebieskie słonie!_
 > - _A jak zabić różowego słonia?_
 
 
Do tej pory widzieliśmy jak komponować funkcje w bardzo ograniczonej formie.
 
````
f: (A) -> B
g: (B) -> C
 
h: (A) -> C = f >>> g
````
 
Nasz świat jest piękny, ale prawdziwe życie wygląda troszeczkę inaczej. W prawdziwym życiu funkcje przyjmują więcej jak jeden argument. Czy można komponować takie funkcje? Jeżeli tak to jak to zrobić?
 
 Na tem moment z tego co wiemy to dwie poniżej funkcje się nie komponują:
*/

func  add(_ x: Int, _ y: Int) -> Int { return x + y }
func incr(_ x: Int)           -> Int { return x + 1 }

/*:
 ## Haskell do pomocy... Haskell Curry
 
 Bez wchodzenia w szczegóły (z checią kiedyś o nich opowiemy, żeby nie było, że to wszystko bierze się z dupy) możemy przetransformować funkcję `add` do lubianego przez nas kształtu, który się banalnie komponuje!
 
 ````
add: (Int, Int) -> Int => add: (Int) -> (Int) -> Int
 ````
 
 lub też używając bardziej generycznego zapisu:
 
  ````
 f: (A, B) -> C => f: (A) -> (B) -> C
  ````
 
 Tak jak mamy zapisaną obecnie funkcję `add` to `A == B == C == Int`. Zobaczmy jak to działa (dla czytelności wersje zcurrowane będę zapisywać z postixem `C`):
 */

func addC(_ x: Int) -> (Int) -> Int {
    return { (y: Int) in
        return x + y
    }
}

/*:
 Zdefiniowałem funkcje, która gdy dam jej argument zwróci mi kolejną funkcję i ta już wyliczy mi właściwy wynik.
 */

assertEqual(add(40, 2), addC(40)(2))

/*:
Przyznaje wywołanie tej drugiej formy nie należy do najpiękniejszych na świecie ;) Natomiast to co na pewno możemy zauważyć to to, że zachowanie obu funkcji jest identyczne. Możemy użyć mądrych wyrazów i powiedzieć, że obie funkcje są _izomorficzne_.
 
 Widząc ten kształ nasuwa się się myśl czy nie można by napisać funkcji, która by zmieniała _interface_ z mniej komponowalnego na bardziej?
*/

func curry<A,B,C>(_ f: @escaping (A,B) -> (C)) -> (A) -> (B) -> C {
    return { a in
        return { b in
            return f(a,b)
        }
    }
}

run("🍛 curry add") {
    let addCurryed = curry(add)
    print(type(of: add), ">===>", type(of: addCurryed))
    
    assertEqual(add(40, 2), addCurryed(40)(2))
}

/*:
 Niestety na dzień dzisiejszy Swift nie ma variatycznych generyków więc albo trzeba takie funkcje wygenerować albo napisać ręcznie. Całe szczęście proces jest bardzo prosty i bez problemu każdy mógłby napisać taką wersję funkcji `curry`, która by wspierała 3,4... ile dusza zapragnie, argumentów.
 
 Bardzo fajną właściwością _izomorfizmu_ jest to, że do pewnego stopnia mamy to samo zapisane trochę inaczej. A to znaczy, że powinniśmy być w stanie napisać funkcję odwrotną co `curry`.
 */

func uncurry<A,B,C>(_ f: @escaping (A) -> (B) -> C) -> (A,B) -> C {
    return { (a: A, b: B) in
        return f(a)(b)
    }
}

run("🍛🗑 uncurry add") {
    let uncurriedAd = uncurry(addC)
    print(type(of: addC), ">===>", type(of: uncurriedAd))

    assertEqual(add(40, 2), uncurriedAd(40, 2))
}

/*:
 Podobnie jak wcześniej funkcję taką dla wiekszej ilości argumentów można wygenerować lub napisać ręcznie.
 
 Currying jest jednym z przydatniejszych narzędzi, ale na pewno nie jedynym. Czas poznać inne ;)
 */

func myPrint(_ message: String, _ times: Int) {
    print( Array(repeating: message, count: times).joined() )
}

/*:
 Jest to dosyć często spotykany kształ funkcji z jaką pracujemy. Jako pierwszy argument mamy to co się zmienia najczęściej a jako drugi (i kolejne) podajemy konfigurację. Oczywiście korzystamy z tego tak:
 */

run {
    myPrint("🍺", 0)
    myPrint("🍺", 1)
    myPrint("🍺", 5)
    myPrint("🍺", 10)
    myPrint("🍺", 15)
}

/*:
Chcielibyśmy jednak osiągnąć taki efekt aby konfigurację podać na samym początku a wiadomość dać jako ostatni argument. Napiszmy więc funkcję, która pozwoli nam umasować to API do takiego z jakim byśmy chcieli pracować:
*/

func flip<A,B,C>(_ f: @escaping (A, B) -> C) -> (B, A) -> C {
    { b,a in f(a,b) }
}

run("🖨 my print will flip!") {
    let flipped = flip(myPrint)
    print(type(of: myPrint), ">===>", type(of: flip(myPrint)))

    flipped(1, "🍺")
    flipped(5, "🍺")
    flipped(10, "🍺")
    flipped(15, "🍺")
}

/*:
Wygląda na to, że jesteśmy w połowie drogi. Konfigurację mamy już na początku. Teraz potrzebujemy jakoś "zapaiętać" to co zostało przekazane i mieć funkcję, która "zaczeka" aż będziemy mieli wiadomość pod ręką.
 
 Pamiętasz tą "brzytką" formę wywołania zcurrowanej funkcji? Chyba już wiesz gdzie to zmierza :D
*/

let flippedMyPrint = flip(myPrint)

run("🚑 Again Haskell Curry to the rescue!") {
    let curriedFlippedMyPrint = curry(flippedMyPrint)
    print(type(of: flippedMyPrint), ">===>", type(of: curriedFlippedMyPrint))
}

/*:
 `(Int) -> (String) -> ()` to jest dokładnie ten typ, który jest nam potrzebny! Gdy dostarczymy konfigurację (ile razy ma się coś wyświetlić). To w zamian dostaniemy funkcję, która wyświetli wiadomość zawsze tą sama ilość razy!
 */

let oneTimeMyPrint = curry(flip(myPrint))(1)

/*:
Możemy nieco uprościć ten zapis skorzystając już z tych operatorów które znamy
*/

let curriedFlipedMyPrint = myPrint |> flip >>> curry
let fiveTimesMyPrint =  curriedFlipedMyPrint(5)

run("🌇 configured my prints!") {
    "💩" |> oneTimeMyPrint
    "🛸" |> oneTimeMyPrint
    "💩" |> fiveTimesMyPrint
    "🛸" |> fiveTimesMyPrint
}

/*:
W tej linijce `myPrint |> flip |> curry` kompozycje widać gołym okiem ;)
 
 I chociaż przykład wydaje się szkolny to gwarantuje dla Ciebie 😜, że jest takie jedno API z którego korzystasz i po prostu musisz **zawsze** przekazywać ten sam argument! (no w 99% przypadkach masz tą samą konfigurację)
*/

let stringData = "Some message".data(using: .utf8)!

run("🌵 WTF 8") {
    let stringFromData = String(data: stringData, encoding: .utf8)!
    print(stringFromData)
}

/*:
Teraz szczerze ;) Kiedy ostatni raz jako encoding uzyłeś/aś czegoś innego jak `utf8`?
*/

let curriedFlipedStringFromData = curry(flip( String.init(data:encoding:) ))
let utf8StringFromData = .utf8 |> curriedFlipedStringFromData

run("🌵💖 utf8") {
    print(
        type(of: String.init(data:encoding:)),
          ">===>",
          type(of: curriedFlipedStringFromData),
          ">== .utf8 ==>",
          type(of: utf8StringFromData)
    )
    
    print(utf8StringFromData(stringData)!)
}

/*:
 Nie musimy się ograniczać tylko do transformowania argumentów. Możemy też transformować "sposób działania" ;)
 */

func makeSynchrone<A, B>(_ asyncFunction: @escaping (A, @escaping (B) -> Void) -> Void) -> (A) -> B {
    return { arg in
        var result: B? = nil

        let queue = DispatchQueue.global(qos: .default)
        
        let group = DispatchGroup()
        group.enter()
        queue.async(group: group) {
            asyncFunction(arg) {
                result = $0
                group.leave()
            }
        }
        
        group.wait()
        
        return result!
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
run("🕍 synchronous magicus!") {
    func myAsyncFunction(arg: Int, completionHandler: @escaping (String) -> Void) {
        // some complicated long computation here
        DispatchQueue.global(qos: .userInitiated).async {
            sleep(UInt32(arg))
            completionHandler("🕍🎉 completion: \(arg)")
        }
    }
    
    print("B4")
    myAsyncFunction(arg: 1) { message in print(#line, message)}
    print("AF")
    
    sleep(2)

    let syncFunction = makeSynchrone(myAsyncFunction)
    print(type(of: myAsyncFunction), ">===>", type(of: syncFunction))

    print("beforek")
    print(syncFunction(3))
    print("afterek")
}

/*:
 Jest jeszcze jeden może zaskakujący kształt, który się pojawia:
 
 ```
 () -> A
 ```
 
 Jest to funkcja, która "z powietrza" dostarcza nam jakąś wartość. Jak możemy stworzyć taką funkcje?
 */

func thunk<A>(_ a: A) -> () -> A {
    return { a }
}

run("🧼 thunk") {
    let value = 42
    let producer = thunk(value)
    
    print(type(of: value), ">===>", type(of: producer))
    
    assertEqual(value, () |> producer)
}

/*:
 Coś takiego może się przydać (i jest używane pod spodem przez bibliotekę standardową) jeżeli z jakiegoś powodu chcemy mieć jakąś wartość i móc o niej _myśleć_ ale nie chcemy odpalać teraz potencjalnie ciężkiego kodu. Mówiąc jeszcze inaczej. Gdy chcemy być leniwi ;)
 
 Nadchodzi jednak taki moment gdzie potrzebujemy tej wartosci. I w tym całym łańcuszku kompozycji też możemy mieć funkcję, która będzie nam zwracać wartość z tej funkcji (cały czas piszemy przepis, żaden kod nie jest uruchamiany).
 
 Za pointfree.co nazwiemy tą funkcje zurry. Aanaglogia do zero argumentowego uncurringu:
 ```
 () -> A |> uncurry => A
 ```
 */

func zurry<A>(_ f: () -> A) -> A { f() }

run {
    let value = 42
    assertAllSame(
        value,
        zurry(thunk(value))
    )
}

/*:
 Oczywiście nic tak nie robi dobrze jak przykład.
 */

tb("⏲ thunk / zurry") {
    let fast = thunk(42)
    let slow: () -> Int = { sleep(UInt32.random(in: 5...8)); return 69 }
    
    (Bool.random() ? slow : fast)
        |> zurry
}

/*:
 ## Partial Application
 
 Zanim zawiniemy tą sekcję, jest jeszcze jeden temat, który może wyskoczyć jak będziesz pytać wójka Googla o pomoc w swoich eskapadach.
 
Jesteśmy przyzwyczajeni do pracy z funkcjami, które przyjmują więcej jak jeden argument na raz i zwracają wartość. Jednak widzieliśmy, że funkcje które przyjmują jeden argument komponują się znacznie prościej.
 
 Jak to jest rozwiązane w językach funkcyjnych?
 
 Przypomnijmy sobie funkcję `add` i `addC`

````
func  add(_ x: Int, _ y: Int) -> Int { return x + y }


func addC(_ x: Int) -> (Int) -> Int {
    return { (y: Int) in
        return x + y
    }
}
````
*/


run("🌥 partial addC") {
    let addOne = addC(1)
    print(type(of: addC), ">===>", type(of: addOne))
    
    print(addOne(41))
}

/*:
 W pewnym sensie widać dlaczego na bloki mówi się domknięcia/closure. Ponieważ, gdy dostarczyliśmy argument `1` to w zamian dostaliśmy funkcję, która domkneła/closes over ten argument w swoim ciele i go "zapamiętała".
 
 Podobny efekt moglibysmy uzyskac np. pisząc `41 |> curry(add)(1)`, ale możemy też sobie zdefiniować funkcję, która dopasuje to za nas (przekaże senns operacji tak jak np. zamiast wszędzie pisac `reduce` piszemy `filter`/`first` etc.)
 */

func partial<A, B, T>(_ f: @escaping (A, B) -> T, _ a: A) -> (B) -> T {
    return { b in f(a, b) }
}

func partial<A, B, C, T>(_ f: @escaping (A, B, C) -> T, _ a: A) -> (B) -> (C) -> T {
    return { b in { c in f(a, b, c) } }
}
    
run("🎭 show partial") {
    let addOne = partial(add, 1)
    
    print(type(of: add), ">===>", type(of: addOne))
    
    print(41, "+ 1 =", addOne(41))
}

/*:
 Oczywiście jeżeli potrzebujemy aby zwrucona funkcja miała inny typ to możemy ją bardzo łatwo do tego przetransformować.
 */

func add3(_ x: Int, _ y: String, _ z: Double) -> [Double] { [z] }

//run("➕ add3") {
    print("C - Curry")
    print("F - Flip")
    print("P - Partial")
    print("U - Uncurry")
    
    func curry<A,B,C,D>(_ f: @escaping (A,B,C) -> (D)) -> (A) -> (B) -> (C) -> D
    {
        { a in
            { b in
                { c in
                    f(a,b,c)
                }
            }
        }
    }
    
    let add3C = curry(add3)
    print("add3C", type(of: add3), ">===>", type(of: add3C))

    let add2C = partial(add3, 1)
    print("add2C",type(of: add3), ">===>", type(of: add2C))

    let add2P = uncurry(partial(add3, 1))
    print("add2P",type(of: add3), ">===>", type(of: add2P))
    
    partial(
        add2P,
        "1"
    )
    
    let addP =
        partial(
            uncurry(partial(add3, 1)), // add2P
            "1"
        )
    print("addP ",type(of: add3), ">===>", type(of: addP))
    
    
    func flip<A,B,C,D>(_ f: @escaping (A,B,C) -> D) -> (C, B, A) -> D {
        return { (c: C, b: B, a: A) in f(a,b,c) }
    }
    
    let add3F = flip(add3)
    print("add3F",type(of: add3), ">===>", type(of: add3F))
    
    let addFP = partial(flip(add3), 1.1)
    print("addFP",type(of: add3), ">===>", type(of: addFP))
    
    let adFPU = uncurry(partial(flip(add3), 1.1))
    print("adFPU",type(of: add3), ">===>", type(of: adFPU))

    let aFPUP = partial(uncurry(partial(flip(add3), 1.1)), "a")
    print("aFPUP",type(of: add3), ">===>", type(of: aFPUP))
//}

/*:
 Na wejściu ZAWSZE była ta sama funkcja. Jednak za każdym razem dostosowaliśmy jej API do tego jak chcielismy. W językach funkcyjnych takie _zabiegi_ są łatwiejsze.
 
 Nie wymagają aż tak zawiłej składni przez co dużo lepiej je się czyta. Natomiast nie wylewajmy dziecka z kompielą ;) W codziennej pracy często dostajemy coś w jakimś formacie i przepychamy na miejsce, które nam bardziej odpowiada. W podejściu funkcyjnym jest dokładnie to samo. Mamy już gotowe narzędzia teraz tylko trzeba coś przemodelować aby można było skorzystać z tego narzędzia.
 
 
 #### One more thing...
  Zobaczmy jak możemy przetransformować to co mamy do tego czego potrzebujemy. Owszem będzie hałaśliwie ale to wynika z tego jak język działa dzis ;)
 */

struct Person: Hashable {
    let name: String
    let age: Int
}

let users = [
    Person(name: "Brajanusz", age: 42),
    Person(name: "Dżesika"  , age: 36),
    Person(name: "Waldemar" , age: 28)
]

run {
    let isGratherThan30Predicate: (Int) -> Bool = { $0 > 30 }

    let comperator: (Int, Int) -> Bool = (>)
    let compFliped = flip(comperator)
    let isGratherThan30 = partial(compFliped, 30)

    let isGratherThan30OneLiner =
        partial(
            flip((>)),
            30
    )

    assertAllSame(
        users
            .filter(^\.age >>> { $0 > 30 }),
        users
            .filter(^\.age >>> isGratherThan30Predicate),
        users
            .filter(^\.age >>> isGratherThan30),
        users
            .filter(^\.age >>> isGratherThan30OneLiner),
        users
            .filter(^\.age >>> partial(flip((>)), 30))
    )
}

/*:
 Dobrze nazwana funkcja sprawia, że kod jest dużo bardzij czytelny. Linijka `filter(^\.age >>> isGratherThan30)` prawie czyta się jak angielskie zdanie ;) Ostatnia natomiast linijka `filter(^\.age >>> partial(flip((>)), 30))` czyta się już mniej optymalnie.

 ---
 
# Podsumowanie

Oczywiście nie pokazaliśmy wszystkich funkcji i operatorów jakie są wykorzystywane w językach funkcyjnych. Z dobrych informacji mam taką, że to o czym tu mówimy teraz nie zależy w żadnym stopniu od języka. Po prostu niektóre ułatwiają taką prace inne można nieco dostosować aby można było w pełni ze wszystkiego skorzystać. Więc tą wiedze można wykorzystać (zmapować 😜) w innych kontekstach.

 Ze złych informacji to mam taką, że to jest dopiero początek. Internet niestety też nie pomaga w odszukiwaniu praktycznych informacji. Bardzo łatwo jest wpaść w pułapkę, gdzie się szuka informacji a odnajduje kolejne pytania.

 Dlatego polecam zacząć powoli i się oswajać, nabierać intuicji. Zaufaj mi kiedy powiem, że wszystko co tu pokazujemy zostało odkryte a nie wymyślone (a jestem pewien czasem czujesz różnice). Daj sobie czas na poczucie jak się z tym pracuje i zacznij od małych kroków.
 
Małe kroczki:
 * zobacz gdzie można użyć mapy (zamiast `if/guard let`)?
 * czy jakąś funkcje można rozbić na mniejsze kawałki na których można budować?
 * postaraj się oswajać z operatorami (na początek: `|>`, `<^>`, `>>>`)
 * budować atomowe funkcje, które razem mozna łączyć w większe całości (jak linuxowe komendy połączone _pałka_)
 
 Powodzenia i do zobaczenia później!
 
 # Inspiracje
 
 * [pointfree.co - there I saw a lot of operators that I show here](https://www.pointfree.co)
 * [Runes - frameworks with more operators](https://github.com/thoughtbot/Runes)
 * [Overture - library for composing functions with ease](https://github.com/pointfreeco/swift-overture)
 * [F# for fun and profit  -- tons of ideas how to apply this concepts in real life](https://fsharpforfunandprofit.com/video/)
 

 
 #### PS
  > - _A jak zabić różowego słonia?_
  > - _Trzeba go mocno złapać za jaja i ścisnąć. Zaczekać aż zrobi się niebieski i rozwalić ze strzelby na niebieskie słonie._
*/


//: [Next](@next)

print("🎪✅")

