//: [Previous](@previous)

import Foundation

/*:
 ## Problem
 Często używamy jakiegoś konkretnego typu do reprezentowania czegoś zupełnie innego.
 
 Np.:
 */

let whoKnows = "1234"
let whatIsIt = "test@gmail.com"

/*:
 Powiedzmy, że mamy jakieś klasy, które spodziewają się że jako parametr otrzymają stringową reprezentację jakiś danych.
 */

struct EmailConsumer {
    func consume(email: String) throws {
        guard email.contains("@") else { throw Ups.notValidEmail(email) }
        
        print("🍽 Consumed email: \(email)")
    }
    
    enum Ups: Error {
        case notValidEmail(String)
    }
}

struct NumberConsumer {
    func consume(number: String) throws {
        guard let _ = Int(number) else { throw Ups.nan(number) }
        
        print("🍽 Consumed number: \(number)")
    }
    
    enum Ups: Error {
        case nan(String)
    }
}


run("🪢 string problem") {
    let stringEmailConsumer  = EmailConsumer()
    let stringNumberConsumer = NumberConsumer()
    do {
        try stringEmailConsumer.consume(email: whoKnows)
        try stringEmailConsumer.consume(email: whatIsIt)
        try stringNumberConsumer.consume(number: whoKnows)
        try stringNumberConsumer.consume(number: whatIsIt)
    }
    catch let err as NSError {
        print(err.debugDescription)
    }
}

/*:
Chcielibyśmy takie rzeczy wyłapywać w czasie kompilacji a nie w czasie działania aplikacji. Aby to zrobić musimy nieco podpowiedzieć czego się spodziewamy.
 
 # Typ Fantomowy
 
 */

struct Phantom<Type, Wrapped> {
    let value: Wrapped
}

/*:
 Więc walczymy z dwoma generykami `Type` oraz `Wrapped`. Ten drugi jest użyty w implementacji. Ten pierwszy nie! Jest widoczny **w czasie kompilacji**, gdy program jest uruchomiony nie ma po nim śladu.

 Potrzebujemy jakiś abstrakcji, które posłużą nam za _dowód_, że coś jest danego typu lub spełnia dane warunki. W Swift mamy dwie możliwości, które pozwalają na stworzenie jakiegoś typy a uniemożliwiają utworzenie instancji. Jednym z nich jest protokół a drugim enumeracja bez żadnych casów.
 
 */

enum Email  {}
enum Number {}

/*:
 Teraz gdzieś w kodzie potrzebujemy _fabryki_, która jest strażnikiem tego aby dana instancja została utworzona tylko w sytuacji gdy spełnia odpowiednie warunki.
 */

func factory(email: String) -> Phantom<Email, String>? {
    guard email.contains("@") else { return .none }
    
    return .init(value: email)
}

func factory(number: String) -> Phantom<Number, String>? {
    guard
        number.isEmpty == false,
        number.first(where: { $0.isNumber == false }) == nil
    else { return .none }

    return .init(value: number)
}

/*:
 Ważne jest aby obie te fabryki były pokryte testami. Dzięki temu w innych miejscach kodu mamy _gwarancje_, że gdy dostaniemy instancje to ona spełnia wszystkie te warunki!
 
 To jest coś bardzo ważnego. Razem z naszym kodem na poziomie kompilacji mamy dowód (certyfikat), że coś spełnia wymogi/kontrakt. W czasie życia aplikacji jest to dalej zwykły String. Tym dowodem jest właśnie to co idzie w miejsce nie używanego generyka. Już nigdzie indziej w kodzie nie muszę sprawdzać czy string jest liczbą czy spełnia warunki bycia emailem!
 
 */

let email  = factory(email: "jest@email.com")
let number = factory(number: "1234")


struct PhantomEmailConsumer {
    func consume(email: Phantom<Email, String>) {
        // No need to check it here! It should be tested in implementation of the factory!
        print("Consumed email: \(email.value)")
    }
}

struct PhantomNumberConsumer {
    func consume(number: Phantom<Number, String>) {
        // "!" is safe, you did test that factory works correctly?
        print("Consumed number:",  Int(number.value)!)
    }
}


run("👗 catching bugs in compilation time!") {
    let emailConsumer = PhantomEmailConsumer()
    let numberConsumer = PhantomNumberConsumer()
    
    email  <^> emailConsumer.consume(email:)
    number <^> numberConsumer.consume(number:)
    
//    number <^> emailConsumer.consume(email:)   // 💥
//    email  <^> numberConsumer.consume(number:) // 💥
    
}

/*:
 Trzeba wsadzić odrobinę wysiłku odnośnie tego jak tworzona jest instancja typu fantomowego. Jeżeli każdy w dowolnym miejscu będzie mógł tworzyć takie instancje, to niestety na nic się to nie przyda bo nie mamy jak _zagwarantować_ faktu, że faktycznie coś spełnia obietnice zawarte w logice fabryki.
 
 Jest kilka sposobów. Można to zrobić za pomocą SwiftLint (tylko niektóre klasy mogą używać init-a tego typu). Trzeba wykazać się czujnością podczas code review. I na koniec można jeszcze wydzielić tą logikę do osobnego modułu, gdzie będzie łatwiej wyłapać niepożądane zmiany.
 
 # Absurd
 
 W serii funkcyjnej opowiadaliśmy o funkcji `absurd`. Jest to taka funkcja, która potrafi stworzyć instancje dowolnego typu! Brzmi magiczne i jak wszystko co się wydaje zbyt piękne było po prostu kłamstwem.
 */

func absurd<A>(_ never: Never) -> A {
  switch never {}
}

/*:
 Problem z tą funkcją jest taki, że nigdy nie dostaniemy instancji typu `Never` aby ją uruchomić. Jednak jest jej bardziej użyteczna wersja, która pozwala _wypełnić brakujące dziury_.
 */

public func undefined<T>(hint: String = "", type: T.Type = T.self, file: StaticString = #file, line: UInt = #line) -> T {
    let message = hint == "" ? "" : ": \(hint)"
    fatalError("undefined \(T.self)\(message)", file:file, line:line)
}

xrun("🌼 undefined in action") {
    let _: String = undefined(hint: "any string")
    let _: Int    = undefined(hint: "any number")
}

/*:
 Funkcja undefined ma jeden problem. Wywołanie jej ubija aplikacje. To do czego jej się to sytuacja gdy trzeba dostarczyć jakąś instancje konkretnego typu ale pisze się inny kod. Ot taki placeholder, który pozwala lecieć z robotą dalej a póżniej dodać właściwe implementacje.
 
 # Wracając do typów fantomowych
 
 Czasami pewne funkcje **muszą** być wywołane w odpowiedniej kolejności. Inaczej aplikacja się wywróci lub jeszcze gorzej będzie działać, a błąd jest na tyle subtelny, że odnajdujemy go bardzo późno.
 
 Wyobraź sobie, że pracujesz w banku i zajmujesz się wnioskami kredytowymi. Każdy taki wniosek przechodzi przez trzy etapy: Aplikacja, Akceptacja, Wypłata. Jeżeli coś jest nie tak na wcześniejszym etapie to nie przechodzi dalej.
 
 Jak można zakodować takie zachowanie i zagwarantować poprawność?
 
 Zacznijmy od pożyczki:
 */

struct Loan {
    enum Status {
        case applied, approved, payed
    }
    
    let amount: Int
    let status: Status
}

/*:
 Dodam zachowania _po staremu_. Załóżmy, że jest to kod we frameworku i tylko "ja" mogę tworzyć instancje pożyczki. Natomiast udostępniam interface do składania wniosku:
 */

func publicApplyForLoan(amount: Int) -> Loan {
    print("Applied for", amount)
    return .init(amount: amount, status: .applied)
}

func internalApprove(loan: Loan) -> Loan {
    print("Approved:", loan.amount)
    return .init(amount: loan.amount, status: .approved)
}

func internalPay(loan: Loan) -> Loan {
    print("Payed:", loan.amount)
    return .init(amount: loan.amount, status: .payed)
}

run("💸 loosing money"){
    let appliedLoan = publicApplyForLoan(amount: 1_000_000)
    let payed = internalPay(loan: appliedLoan)
    internalApprove(loan: payed)
}

/*:
 Problemu można uniknąć dodając dodatkowe walidacje w każdej z tych metod. Jednak tracimy wtedy czytelność każdej z nich. Dochodzi też ryzyko rozmycia przez cały system (więcej metod, klas) odpowiedzialności co to znaczy "zaakceptować pożyczkę".
 
 Zobaczmy jak typy fantomowe mogą nam w tym pomóc.
 
 */

enum LoanProcess {
    enum Applied {}
    enum Approved {}
    enum Payed {}
}

func publicApplyFor(amount: Int) -> Phantom<LoanProcess.Applied, Loan> {
    print("Applied for", amount)
    let loan = Loan(amount: amount, status: .applied)
    return .init(value: loan)
}

func internalApprove(loan phantom: Phantom<LoanProcess.Applied, Loan>) -> Phantom<LoanProcess.Approved, Loan> {
    print("Approved:", phantom.value.amount)
    let loan = Loan(amount: phantom.value.amount, status: .approved)
    return .init(value: loan)
}

func internalPay(loan phantom: Phantom<LoanProcess.Approved, Loan>) -> Phantom<LoanProcess.Payed, Loan> {
    print("Payed:", phantom.value.amount)
    let loan = Loan(amount: phantom.value.amount, status: .payed)
    return .init(value: loan)
}

run("🔒 secure money - change order and see what happens"){
    let appliedLoan = publicApplyFor(amount: 1_000_000)
    let approved = internalApprove(loan: appliedLoan)
    internalPay(loan: approved)
}

/*:
 Tworzenie tych dodatkowych zmiennych też jest strasznie upierdliwe. Dodatkowo same funkcje (zachowania) muszą przyjmować już instancje typu `Phantom`. Zobaczmy co z tym możemy zrobić.
 */

extension Phantom {
    @discardableResult
    func process<To>(_ transform: @escaping (Phantom<Type, Wrapped>) -> Phantom<To, Wrapped>) -> Phantom<To, Wrapped> {
        transform(self)
    }
}

run ("🔀 process - change order and see what happens") {
    publicApplyFor(amount: 1_000_000)
        .process( internalApprove(loan:) )
        .process( internalPay(loan:) )
}

/*:
Takie API jest bardziej ergonomiczne. Ukrywa detal przechodzenia przez owijkę na typ fantomowy. Jednak to, że musimy przez nią przechodzić jest pewną niewygodą. Natomiast w moim odczuciu warto. Gdy system typów w Swift nieco dojrzeje to będzie można nieco wygładzić i ten problem.
 
 Reasumując:
 
 Zyskujemy bezpieczeństwo, że gdy coś pójdzie nie tak to kompilator powstrzyma nas przed drogim babolem.
 
 Nie musimy w każdej metodzie sprawdzać, czy wniosek na wejściu jest w odpowiednim statusie. Ułatwia to development takich metod. Ktoś mógł zapomnieć sprawdzić. To jest prosta logika ale jak tych warunków by było więcej to taka metoda przestaje być czytelna. I jak by tego jeszcze było mało to w różnym czasie zasady się mogą zmienić. Jaka jest gwarancja, że aktualizacja odbyła się wszędzie w całym systemie?

 ## Linki
 
 Warto rzucić okiem na poniższe linki. Bardzo inspirujące
 
 * [ObjC.io Phantom Types](https://www.objc.io/blog/2014/12/29/functional-snippet-13-phantom-types/)
 * [Realm Academy - The Type System is Your Friend](https://academy.realm.io/posts/swift-summit-johannes-weiss-the-type-system-is-your-friend/)
 * [Hacking with Swift - How to use phantom types in Swift](https://www.hackingwithswift.com/plus/advanced-swift/how-to-use-phantom-types-in-swift)
 * [Natasha The Robot](https://www.natashatherobot.com/swift-money-phantom-types/)
 * [Objc.io - Functional Snippet #13: Phantom Types](https://www.objc.io/blog/2014/12/29/functional-snippet-13-phantom-types/)
 * [Swift by Sundell - Phantom types in Swift](https://www.swiftbysundell.com/articles/phantom-types-in-swift/)
 * [Supercharge your handles using phantom types](https://luctielen.com/posts/supercharge_your_handles_with_phantom_types/)
 * [objc.io - Swift Talk # 153 Making Impossible States Impossible](https://talk.objc.io/episodes/S01E153-making-impossible-states-impossible)
*/

//: [Next](@next)
