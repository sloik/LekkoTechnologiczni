//: [Previous](@previous)

import Foundation

NSSetUncaughtExceptionHandler{print("💥 Exception thrown: \($0)")}


/*:
 # Map 🗺
 
 Zobaczyliśmy już jak bardzo uniwersalna jest funkcja map. Jednak dalej brakuje nam intuicji kiedy map to jest **ta** mapa i co więcej, które typy są "mapowalne".
 
 # Prawa Map-y?

 Wiemy, że Map-a mapuje (oh daaa!) jedną kategorię (typ) i ich morfizmy (związki między obiektami [typami]) w drugą, zachowując ich strukturę.


                   ┌─┐   map next   ┌─┐   map next   ┌─┐
     ─ ─ ─ ─ ─ ─ ─▶│B│─────────────▶│C│─────────────▶│D│─ ─ ─ ─ ─ ─ ─▶
                   └─┘              └─┘              └─┘
                   │ ▲              │ ▲              │ ▲
                   │ │ map upper    │ │ fmap upper   │ │ map upper
                   │ │              │ │              │ │
                   │ │              │ │              │ │
         map lower │ │   map lower  │ │    map lower │ │
                   ▼ │              ▼ │              ▼ │
                   ┌─┐              ┌─┐              ┌─┐
     ─ ─ ─ ─ ─ ─ ─▶│b│─────────────▶│c│─────────────▶│d│─ ─ ─ ─ ─ ─ ─▶
                   └─┘   map next   └─┘   map next   └─┘
 
 Na diagramie widać jak mając funkcję `next` i dając jej argument `b` dostajemy jako wynik `c`, który ... itd. Za pomocą `map` przenosimy zachowanie funkcji `next` z małych liter do dużych `"a".map(upper)`. Często mówi się o podnoszeniu/lift.
 
 Widać, że mamy zachowaną tu nie tylko strukturę (a,b,c... A,B,C) ale też relacje między tymi obiektami. Następną literą po `b` jest `c` i ta relacja została zmapowana do wielkich liter. Czyli następną literą po `B` jest `C`.

 Mówiąc bardziej abstrakcyjnie. Gdy mamy funkcję (A) -> B i chcemy ją zmapować do funkcji ( f(A) ) -> f(B) to chcemy zagwarantować, że obiekty i funkcje są *niezmienione* podczas tego procesu.

 Ponownie na czymś konkretnym:

Optional _podnosi_ funkcje A -> B do funkcji A? -> B? przy czym relacja między A i B pozostała bez zmian.
 */
func  len(_ x: String) -> Int { x.count } // A -> B

let optionalLen: (String?) -> Int? = map(len) // (A) -> -- map -> (A?) -> B?

let trueString: String  = "Andrzeju"
let someString: String? = trueString

assertAllSame(
    len(trueString),
    optionalLen(someString),
    optionalLen(trueString)
)

/*:
 
 I aby _zagwarantować_ takie zachowanie mapa musi przestrzegać kilku praw:

 # map id == id

 To prawo gwarantuje, że mapa nie zmieni struktury.

 */

extension Array {
  func myMap<T>(_ transform: (Element) -> T) -> [T] {
     var returnContainerItems: [T] = []
    
     for item in self {
         returnContainerItems.append( transform(item) )
     }
    
    return returnContainerItems
  }
}

let numbersArray = [1,2,3,4]

assertEqual(
    numbersArray.myMap(identity),
    identity(numbersArray)
)

/*:
 Aby spełnić to prawo mapa dla tablic może być zaimplementowana tylko w jeden sposób! Jeżeli tylko w jakikolwiek sposób zmienimy strukturę to prawo mapy nie zostanie zachowane.
 */

extension Array {
    func fake1Map<T>(_ transform: (Element) -> T) -> [T] {
        return []
    }
    
    func fake2Map<T>(_ transform: (Element) -> T) -> [T] {
        var returnContainerItems: [T] = []
        for item in self {
            returnContainerItems.append(transform(item))
            returnContainerItems.append(transform(item))
            
        }
        return returnContainerItems
    }
    
    func fake3Map<T>(_ transform: (Element) -> T) -> [T] {
        var returnContainerItems: [T] = []
        for item in self {
            returnContainerItems.append(transform(item))
        }
        returnContainerItems.reverse()
        return returnContainerItems
    }
}

assertEqual( numbersArray.fake1Map(id), numbersArray )
assertEqual( numbersArray.fake2Map(^\.self), numbersArray )
assertEqual( numbersArray.fake3Map(id), numbersArray )

/*:
 Tak samo dla Optional-a:
 */

extension Optional {
  func myMap<T>(_ transform: (Wrapped) -> T) -> T? {
    switch self {
    case              .none: return .none
    case .some(let wrapped): return .some( transform(wrapped) )
    }
  }
}

someString
let noneString: String? = nil

assertEqual(someString.myMap(^\.self), someString)
assertEqual(someString.myMap(id), String?.some("inny string"))

assertEqual(noneString.myMap(id), noneString)
assertEqual(noneString.myMap(id), someString) // .none != .some


extension Optional where Wrapped == String {
    func fake1Map<T>(_ transform: (Wrapped) -> T) -> T? {
        return .none
    }
    
    func fake2Map<T>(_ transform: (Wrapped) -> T) -> T? {
        switch self {
        case             .none: return .none
        case .some(let wrapped): return .some( transform(wrapped + wrapped) )
        }
    }
}

assertEqual(someString.fake1Map(id), someString)
assertEqual(someString.fake2Map(id), someString)

/*:
# map ( f  >>>  g ) == map( f ) >>> map( g )

 Mapa kompozycji powinna być taka sama jak kompozycja map.
*/

func incr(_ i: Int) -> Int { i + 1 }

let f = len
let g = incr

let fThenG = f >>> g

assertEqual(
    trueString <^> fThenG, // map( f >>> g )
    trueString <^> f <^> g // map( f ) >>> map( g )
)

assertEqual(
    trueString <^> f >>> g,
    trueString <^> f <^> g
)

/*:
Lub:
 */

func appendBang(_ s: String) -> String { s + "!" }

["A", "B", "C"]
    .myMap(^\.localizedLowercase >>> appendBang)

["A", "B", "C"]
    .myMap(^\.localizedLowercase).myMap(appendBang)

/*:
Można powiedzieć, że pierwsza wersja jest _wydajniejsza_ ponieważ tworzymy tylko jedną kolekcję. W drugim przypadku są tworzone dwie. Są natomiast języki gdzie wiedzą o tym, że mapa ma taką właściwość i kompilator sam dokonuje tej optymalizacji. Swift jeszcze tam nie jest ;)
 */

assertEqual(
    ["A", "B", "C"].myMap(^\.localizedLowercase  >>>   appendBang),
    ["A", "B", "C"].myMap(^\.localizedLowercase).myMap(appendBang)
)

/*:
# Fajne ale po co to komu?

 Na chwilę obecną widzieliśmy, że możemy "mapować" tablice i optionale. Jednak jest całe ZOO typów, które mają właśnie w ten sposób zdefiniowaną mapę. Apple razem z Combine dorzucił masę dodatkowych typów, które są mapowalne. Więc jest po pomysł dużo szerszy niż tablice i optionale. Ha! Nawet dużo szerszy niż sam Swift!
 
 Gdyby język pozwolił nam na łatwe powiedzenie, że jakiś typ jest mapowalny. Czyli ma zdefiniowaną na sobie funkcję map, która spełnia te prawa. To **moglibyśmy pisać programy bez wiedzy co to jest za typ!**.
 
 To jest takie ważne, że powtórzę to jeszcze raz. **Można pisać generyczne programy/algorytmy bez interesowania się z jakim konkretnie typem mamy do czynienia**. Interesuje nas tylko to, że możemy po nim mapować.
 
 # Funktor
 
 Jeżeli Was zainteresował temat to _Funktor_ jest tym słowem, które chcecie wpisać w Google. Kolejnym jakie wyskoczy zaraz obok niego jest _type class_. Można o tym myśleć jak o _protocol with asossiated type_ tylko ze ten PAT w tym wypadku to `Self` (typ, który implementuje ten protokół).
 
 Niestety na dzień dzisiejszy Swift nie wspiera Type Class. Chociaż w Generic Manifesto jest wspomniane, że jest w planach. Kiedy... kto to wie, pewnie mają dużo więcej bardziej pilnej roboty.
 
 ## Nadzieja
 
 Czy to znaczy, że to wszystko było na marne? Nie :) To o czym teraz mówimy jest uniwersalne. W każdym języku funkcje się komponują a _funktory_ mapują ;) Warto nabierać intuicje i wiedzieć czego się szuka.
 
 Z dobrych wiadomości to jeszcze mam taką, że istnieje biblioteka **Bow Swift**, która _emuluje_ **Higher Kinded Type**s w Swift już dziś. Zachęcam chociaż na rzucenie okiem do dokumentacji.
 
 ## Co dalej?
 
 Mam nadzieje, że było widać iż mapa już teraz jest użyteczna. W przyszłości chcemy pokazać więcej typów, które mają operacje map na sobie zaimplementowaną.
 
 Owocnej nauki :D

 # Linki

 * [George Wilson - The Extended Functor Family](https://youtu.be/JZPXzJ5tp9w)
 * [Bow Swift GithHub](https://github.com/bow-swift/bow)
*/
print("🍌")
//: [Next](@next)
