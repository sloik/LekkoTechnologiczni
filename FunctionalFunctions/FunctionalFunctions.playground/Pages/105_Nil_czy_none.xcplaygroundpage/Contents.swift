//: [Previous](@previous)

import Foundation

/*:
 # Nil czy none?

 Czym się różnią od siebie:
 */


func i1() -> Int? { 42        }
func i2() -> Int? { .some(42) }
func i3() -> Int? { nil       }
func i4() -> Int? { .none     }

func i5() -> Optional<Int> { 42        }
func i6() -> Optional<Int> { .some(42) }
func i7() -> Optional<Int> { nil       }
func i8() -> Optional<Int> { .none     }

type(of: i1)
type(of: i2)
type(of: i3)
type(of: i4)
type(of: i5)
type(of: i6)
type(of: i7)
type(of: i8)

i3() == .none
i4() == nil

nil == ()


/*:
 Wygląda na to, że niczym. Typ mają identyczny a jednak jedna implementacja jawnie mówi co się dzieje a druga nieco trochę mniej.

 ## Gen Objective-C

 Dla kogoś kto zaczynał z ObjC 'nil' nie jest nowym pomysłem. Ot magiczna wartość (0x0), która oznacza, że nic nie ma. Jednak Swift miał dać nam nowy świat, miał przywrócić równowagę. Swift dał nam `Optional`, który jak wiemy jest enumem:
 */

enum MyOptional<Wrapped> {
    case some(Wrapped)
    case none
}


/*:
 Nie ma tu słowa o nilu a jednak jak widzieliśmy możemy go używać. Co więcej wygląda na to, że nil i none są sobie równe... o co tu chodzi?

 Właśnie o tą historię z ObjC. Apple musiało (serio?) ułatwić przesiadkę z ObjC na Swift. Nil jest właśnie dla tych developerów, którzy mają w głowie asocjacje, że _nil_ to brak wartości. Lub będąc bardziej dokładnym w świecie ObjC specjalna wartość 0x0, która oznacza brak wartości.

Związek ObjC z nil jest jeszcze o tyle ciekawy, że w wypadku wysłania _message_ do nil aplikacja nie crashowała. W przeciwieńswtwie do innych języków, które słyną z _null pointer exeption_.

 W Swift _nil_ nie istnieje. W momencie gdy nie jest przypisany do żadnej zmiennej dostaniemy błąd _'nil' requires a contextual type_. Jest to kolejny fragment gdzie Swift stara się być bezpieczny.

 # Nasz własny nil

 Rzut okiem na [dokumentacje](https://developer.apple.com/documentation/swift/expressiblebynilliteral) i zobaczymy coś bardzo ciekawego:

 > Only the Optional type conforms to ExpressibleByNilLiteral

 Możemy wnioskować z tego, że nil nie istnieje w Swift. Gry rzucimy okiem do dokumentacji zobaczymy, że wystepuje tam [nil-literal](https://docs.swift.org/swift-book/ReferenceManual/LexicalStructure.html#grammar_nil-literal)

 ```
 GRAMMAR OF A LITERAL

 literal → numeric-literal | string-literal | boolean-literal | nil-literal

 numeric-literal → -opt integer-literal | -opt floating-point-literal

 boolean-literal → true | false

 nil-literal → nil
 ```

 Nieco wcześniej możemy przeczytać też:

 ```
 A literal is the source code representation of a value of a type, such as a number or string.

 42               // Integer literal
 3.14159          // Floating-point literal
 "Hello, world!"  // String literal
 true             // Boolean literal

 A literal doesn’t have a type on its own. Instead, a literal is parsed as having infinite precision and Swift’s type inference attempts to infer a type for the literal.
 ...
 When specifying the type annotation for a literal value, the annotation’s type must be a type that can be instantiated from that literal value...
 ```
 */

extension MyOptional: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self = .none
    }
}


func mi1() -> MyOptional<Int> { .some(42) }
func mi2() -> MyOptional<Int> { nil }

/*:
 Jednak to nie jedyny cukier składniowy jaki posiada Optional a chwilowo brakuje naszmu typowi ;)
 */

struct _MyOptionalNilComparisonType: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {}
}

extension MyOptional {
    static func ~=(lhs: _MyOptionalNilComparisonType, rhs: MyOptional<Wrapped>) -> Bool {
      switch rhs {
      case .some: return false
      case .none: return true
      }
    }

    static func ==(lhs: MyOptional<Wrapped>, rhs: _MyOptionalNilComparisonType) -> Bool {
      switch lhs {
      case .some: return false
      case .none: return true
      }
    }

    static func ==(lhs: _MyOptionalNilComparisonType, rhs: MyOptional<Wrapped>) -> Bool {
      switch rhs {
      case .some: return false
      case .none: return true
      }
    }

    static func !=(lhs: MyOptional<Wrapped>, rhs: _MyOptionalNilComparisonType) -> Bool {
      switch lhs {
      case .some: return true
      case .none: return false
      }
    }

    static func !=(lhs: _MyOptionalNilComparisonType, rhs: MyOptional<Wrapped>) -> Bool {
      switch rhs {
      case .some: return true
      case .none: return false
      }
    }
}

run("🍔") {
    switch mi1() {
    case   nil: print("nil")
    case .some: print("some")
    case .none: print("none")
    }

    switch mi2() {
    case   nil: print("nil")
    case .some: print("some")
    case .none: print("none")
    }

    if mi2() == nil {
        print("nil in if")
    }

    if nil == mi2() {
        print("nil in if")
    }
}

/*:
 Odzyskaliśmy odrobinę tej ergonomii, która jest związana z pracą z typem Optional. Jednak aby mieć 100% pewność że `nil nie istnieje` możemy jeszcze rzucić okiem na SIL dla kodu:
 */

func d() -> Int? { 42 }

var t = d() == nil

/*:
 SIL:

     // d()
     sil hidden [ossa] @main.d() -> Swift.Int? : $@convention(thin) () -> Optional<Int> {
     bb0:
       %0 = integer_literal $Builtin.IntLiteral, 42    // user: %3
       %1 = metatype $@thin Int.Type                   // user: %3
       // function_ref Int.init(_builtinIntegerLiteral:)
       %2 = function_ref @Swift.Int.init(_builtinIntegerLiteral: Builtin.IntLiteral) -> Swift.Int : $@convention(method) (Builtin.IntLiteral, @thin Int.Type) -> Int // user: %3
       %3 = apply %2(%0, %1) : $@convention(method) (Builtin.IntLiteral, @thin Int.Type) -> Int // user: %4

       %4 = enum $Optional<Int>, #Optional.some!enumelt.1, %3 : $Int // user: %5
       return %4 : $Optional<Int>                      // id: %5
     } // end sil function 'main.d() -> Swift.Int?'

 Jak widać zwracana jest wartość `%4`, która to ma taką definicję: `enum $Optional<Int>, #Optional.some!...`. Czyli zwracamy `.some`.

 Zobaczmy jak wygląda SIL gdy funkcja _zwraca nil_
 */

func dd() -> Int? { nil }

t = dd() == nil

/*:
SIL:

    // dd()
    sil hidden [ossa] @main.dd() -> Swift.Int? : $@convention(thin) () -> Optional<Int> {
    bb0:
      %0 = metatype $@thin Optional<Int>.Type

      %1 = enum $Optional<Int>, #Optional.none!enumelt // user: %2
      return %1 : $Optional<Int>                      // id: %2
    } // end sil function 'main.dd() -> Swift.Int?'

Tym razem `%1` ma definicję: `enum $Optional<Int>, #Optional.none!...`.


 # Podsumowanie

 Łyżka... nil nie istnieje. Jest to tylko cukier składniowy aby przesiadka z ObjC na Swift była mniej bolesna(?). Moim osobistym zdaniem zwracanie `.none` jest czytelniejsze od `nil`. Nil niesie ze sobą cały bagaż doświadczeń i skojarzeń (nie wierzycie to porozmawiajcie z innymi developerami, oni są jeszcze w ObjC). Gdzie `.none` takich nie posiada. Z drugiej strony bardzo doceniam to, że dla Optionali nie muszę opakowywać wszystkiego w `.some` gdy zwracana jest jakaś wartość lub przypisywana do zmiennej.

 ## Dlaczego uważam, że jest to mało _fortunne_?

 Ponieważ jest masa typów, które na nieco wyższym poziomie są identyczne. Z optionalem pracuje się tak samo jak z Either, Result, Try, Future... itd. Ponieważ Optional ma wiele _cukru skłądniowego_ ba czasem nawet specjalną składnie, patrz _if let etc._, to tracimy tą intuicję jak korzystać z tej abstrakcji. Jedną nogą pozostając w ObjC.

 Może powoli czas rzucić to ObjC i zrezygnować z nil? Szczególnie, że jeżeli ktoś nie ma tego bagażu doświadczeń? Do rozważenia przez każdego we własnym zakresie ;)

 ## Po co to było?

 Optional jest jednym z typów, które można zgrupować pod jedną nazwą (Monada) ale w Swift jest specjalny. Ma specjalną składnie, czy to jest zwracany czy przypisywany do zmiennej. W specjalny sposób dobieramy się do jego wartości czy też sprawdzamy czy coś jest. Robimy to tak jak byśmy dalej programowali w ObjC. To sprawia, że przegapiamy wiele innych podobnych typów z którymi możemy pracować w ten sam sposób... ale o tym opowiemy w przyszłości ;)

 ### Lineczki
 * [kompilator ma specjalna wiedzę](https://github.com/apple/swift/blob/da61cc8cdf7aa2bfb3ab03200c52c4d371dc6751/stdlib/public/core/Optional.swift#L123)
 * [Optional konformuje do ExpressibleByNilLiteral](https://github.com/apple/swift/blob/da61cc8cdf7aa2bfb3ab03200c52c4d371dc6751/stdlib/public/core/Optional.swift#L203)
 * [W debagu wypisuje nil zamiast none](https://github.com/apple/swift/blob/da61cc8cdf7aa2bfb3ab03200c52c4d371dc6751/stdlib/public/core/Optional.swift#L277)
 * [To powinno wyglądać znajomo ;)](https://github.com/apple/swift/blob/da61cc8cdf7aa2bfb3ab03200c52c4d371dc6751/stdlib/public/core/Optional.swift#L401)
 * [Optionals in Objective-C](https://engineering.facile.it/blog/eng/optionals-in-objective-c/)
*/


print("🥳")

//: [Next](@next)
