//: [Previous](@previous)

import Foundation

NSSetUncaughtExceptionHandler{print("💥 Exception thrown: \($0)")}

/*:
 
 # Capabilities
 
 ---

To jest luźna interpretacja. Nie definiuję pojęcia obiektu ale nim się bawię.

 Tak więc _obiekt_ to wewnętrzny stan z połączonym zachowaniem. Klasa posiada metody i wewnętrzne property do których udostępnia set-ery i get-ery. Gdyby wywinąć ten model na drugą stronę to można powiedzieć, że chcemy mieć zachowanie z ukrytym stanem.
 */

func counter() -> () -> Int {
    var internalCounter = 0

    return {
        internalCounter += 1
        return internalCounter
    }
}

/*:
 
 Funkcja `counter` w pewnym sensie jest fabryką funkcji. Gdy zostanie wywołana to zwróci kolejną funkcje. Najciekawsza część to zmienna `internalCounter`. Jest ona _łapana_ przez blok, który jest zwracany.
 
 Efekt tego jest taki, że każda zwrócona funkcja ma swój własny prywatny stan. Nie można się do niego w żaden sposób dobra. Jeżeli chodzi o ukrywanie danych to jest to absolutne mistrzostwo!
 
 Czas zobaczyć, że tak faktycznie jest!
 */

run("👾 running counter") {
    let functionFactory = counter
    
    let oneCounter = functionFactory()
    let yetAnotherCounter = functionFactory()
    
    print("Line:", #line, "State for one counter:", oneCounter())
    print("Line:", #line, "State for one counter:", oneCounter())
    print("Line:", #line, "State for one counter:", oneCounter())
    print("Line:", #line, "  Yet another counter:", yetAnotherCounter())
}

/*:
 Na początku wydaje się to dziwne, jednak ten sam kod można napisać tak:
 */

func classCounter() -> () -> Int {
    final class InternalClass {
        var internalCounter = 0
        func count() -> Int {
            internalCounter += 1
            return internalCounter
        }
    }
    
    let instance = InternalClass()
    return instance.count
}

/*:
 Tym razem stan jest zamknięty w wewnętrznej klasie. Co jest zwracane? Funkcja typu `() -> Int` (musi, taki jest zadeklarowany typ). Ta funkcja jednak jest zwracana w nietypowy sposób `instance.count`. Kiedyś o tym mówiliśmy więc teraz nie będę się powtarzać (odcinek o funkcjach).
 
 Czy to działa tak samo?
 */

run("🧤 running counter as class") {
    let functionFactory = classCounter
    
    let oneCounter = functionFactory()
    let yetAnotherCounter = functionFactory()
    
    print("Line:", #line, "State for one counter:", oneCounter())
    print("Line:", #line, "State for one counter:", oneCounter())
    print("Line:", #line, "State for one counter:", oneCounter())
    print("Line:", #line, "  Yet another counter:", yetAnotherCounter())
}

/*:
 Działa :)
 
 # Funkcja jako interface
 
 Piękno funkcji polega na tym, że ma jasno zdefiniowane wejście i wyjście.
 */

/// Adds one to passed int argument.
func increment(_ i: Int) -> Int {  i + 1 }

/// For given int returns string representation.
func toString(_ i: Int) -> String { String(i) }

/*:
 Tych funkcji możemy użyć tak:
 */

run("☄️ Basic call stuff") {
    print("                  Calling increment: ", increment(42) )
    print("Calling increment and then toString: ", toString( increment(42) ) )
}

/*:
 
 ## Potrzeba inspekcji argumentów
 
 Jak było już pokazywane wielokrotnie. Taki sposób wywoływania metod/funkcji jest mało poręczny. W dalszych przykładach będę używał operatorów.
 
 Aby nieco lepiej zrozumieć co się dzieje w aplikacji (przykład jest sztuczny, ale zastosowanie już niekoniecznie) mogę potrzebować funkcji, która wypisze podany argument i go zwróci.
 */

func log<A>(_ a: A) -> A {
    print(a, type(of: a))
    return a
}

/*:
 Funkcja jest generyczna po jednym typie. Jedyne co z nim robi to wypisuje w konsoli. Następnie go zwraca. To w sumie daje nam dwie rzeczy...
 */

run("🍉 Same with operators") {
    print(
        "Increment and toString:",
        42 |> increment |> toString
    )
    __
    
    print(
        "Same thing but with logs",
        42 |> log |> increment |> log |> toString |> log
    )
}

/*:
 W konsoli jasno widać, że: do funkcji increment na wejściu była przekazana wartość 42. Została potem przekazana do funkcji toString i ponownie wypisana.
 
 Zapis _log |> funkcja |> log_ jest troszeczkę hałaśliwy. Trudniej jest zauważyć co taki _pipeline_ faktycznie będzie robił. Co jeżeli chcemy mieć nieco lepszą czytelność?
 
 Można takie funkcje złożyć/skomponować ze sobą.
 */

/// Logs input, increments, logs output.
let logIncrement = log >>> increment >>> log

/// Logs input, runs toString, logs output.
let logToString  = log >>> toString  >>> log

/*:

 Wracając do wątku jakim jest _funkcja jako protokół_ (chociaż bardziej by pasował wyraz interface).
 
 Niżej zdefiniuję funkcję, która będzie przyjmować argument i funkcje w jakiś sposób operującą na tym argumencie. Typ argumentów do tej funkcji to właśnie _interface_. Równie dobrze mógłbym zażyczyć aby to była instancja konformująca do jakiegoś protokołu.
 
 Dlaczego więc funkcja?
 
 Bo funkcje są znacznie prostsze! Wymagają mniej ceremonii. I się komponują!
 
 */

func function<A, B>(
    _ on: A,
    _ act: (A) -> B
) -> B {
    act( on )
}

run("🧅 Composed/Decorated function has the same interface") {
    print(
        "Same output?",
        assertEqual(
            function(42, increment),
            function(42, logIncrement)
        )
    )
    
}

/*:
 Po wydruku jasno widać, że obie zwracają tą samą wartość. Jednak działanie drugiej można prześledzić krok po kroku.
 
 Cały czas jednak mamy pewien problem. Kod jest prosty i dość łatwo jest śledzić kontekst. Jeżeli takich wywołań będzie więcej to super by było zostawić sobie jakąś wskazówkę.
 */

func logWithMessage<A>(_ message: String) -> (A) -> A {
    return { input in
        print(message, input, type(of: input))
        return input
    }
}

/*:
 Gdy przekazana zostanie wiadomość to funkcja zwróci kolejną funkcję, która po prostu wypisze w konsoli to co chcemy.
 */

run("📝 Could be used for logging...") {
    let someStuffToBeDone = logWithMessage("Inout is: ")
                                >>> increment
                                >>> logWithMessage("Output is: ")
    
    function(42, someStuffToBeDone)

    __

    let result =
        42
            |> logWithMessage("First there is: ")
            |> increment
            |> logWithMessage("Result of increment is: ")
            |> logWithMessage("We are taking it as input to str")
            |> toString
            |> logWithMessage("and the final result of computation is: ")

    type(of: result)
}

/*:
 Pierwszy przykład wykorzystuje operator kompozycji funkcji. Referencja `someStuffToBeDone` ma typ `(Int) -> Int` co dokładnie odpowiada typowi funkcji `increment`. **Funkcja increment została udekorowana nowym zachowaniem!**.
 
 Drugi przykład jest nieco bardziej rozbudowany. Dużo więcej w nim wskazówek, które zaciemniają intencje/cel samego pipe-lina. Jednak w nagrodę mamy bardzo ładny opis tego co się dzieje.
 
 # Capabilities

 _Capability_ to zdolność do zrobienia czegoś. Do tej pory zyskaliśmy zdolność do logowania. Jednak można ten pomysł popchnąć znacznie dalej.
 
 ## Interface
 
 Dostęp do bazy danych powinien być bezpieczny. Powiedzmy gdzieś w odmętach produkcji jest funkcja, która gdy damy Id użytkownika to zwróci nam jego imię. Ponieważ używamy produkcyjnego API przez sieć to taka operacja może się nie udać.
 */

func getUser(_ id: Int) -> String? {
    switch id {
    case 1:  return "👧🏼 Alice"
    case 2:  return "👦🏻 Bob"
    default: return "👮‍♀️ Not Alice or Bob!"
    }
}

/*:
 Ładne? Oto moja prywatna, szerzona baza danych. Kontrakt się zgadza w 100% z opisem! Nawet można sprawdzić czy działa:
 */

run("👧🏼👦🏻👮‍♀️ Getting user directly with a method") {
    print(
        getUser( 1) as Any,
        getUser( 2) as Any,
        getUser( 42) as Any,
        separator: "\n"
    )
}

/*:
 Na zewnątrz chcę upublicznić tylko publiczny interface tej funkcjonalności. Niestety coś takiego po prosty trzeba _oszukać_ w placu zabaw. Jednak łatwo sobie wyobrazić, że definiuje jakiś publiczny kawałek biblioteki a metoda `getUser` jest jego detalem.
 */

/// Public interface for getting user from a DB
/// over network.
let capabilityGetUser: (Int) -> String? = getUser

/*:
 Typ `(Int) -> String?` zawiera cały kontrakt a działa tak:
 */

run("📀 Getting user thru an abstract interface... this case (Int) -> String?") {
    print(
        capabilityGetUser(1) as Any,
        capabilityGetUser(2) as Any,
        capabilityGetUser(42) as Any,
        separator: "\n"
    )
}

/*:
 Rezultat jest oczywiście dokładnie taki sam gdy wołana została funkcja `getUser`. Jednak ta ekstra referencja ukrywa detal implementacyjny. Służy jako interface/protokół do tej _zdolności_.
 
 ## Ograniczanie ilości zawołań
 
 Wykorzystując sposób z samego początku, można stworzyć taką capability, która pozwoli wywołać się tylko określoną ilość razy.
 
 */

func limit<A,B>(
    capability: @escaping (A) -> B?,
    times: Int) -> (A) -> B? {
    
    // Storage captured by the inner function / block
    var localLimit = times
    
    func decorator(_ a: A) -> B? {
        guard localLimit > 0  else { return nil }
        localLimit -= 1
        
        return capability(a)
    }
    
    // returns reference to created function
    return decorator
}

/*:
 Funkcja dekoruje przekazane capability o sprawdzenie ile razy już została wywołana. Zobaczmy...
 */

/// Can get user only 3 times.
let getUserMax3Times = limit(
    capability: capabilityGetUser,
    times: 3
)

type(of: getUserMax3Times) == type(of: capabilityGetUser)

run("🧮 Now this capability will work only three times!") {
    print(
        "Time 1: \( getUserMax3Times(1)  as Any )",
        "Time 2: \( getUserMax3Times(2)  as Any )",
        "Time 3: \( getUserMax3Times(42) as Any )",
        "Time 4: \( getUserMax3Times(1)  as Any )",
        "Time 5: \( getUserMax3Times(2)  as Any )",
        "Time 6: \( getUserMax3Times(42) as Any )",
        separator: "\n"
    )
}

/*:
 Niestety aby się coś ładnie wydrukowało w terminalu to trzeba poszaleć z formatowaniem. Jednak gdy się już uda przebić przez ten szum to widać, że po prostu dla kolejnych użytkowników jest wywoływana funkcja `getUserMax3Times`. Zgodnie z obietnicą wywołanie po limicie zwraca `.none`.
 
 Polecam pobawić się tym fragmentem i rzucić okiem na implementacje `limit(capability:times:)`. Zaskakujące ile potrafi zwykła funkcja!
 
 ## Audyt
 
 Dobry system powinien pozwolić na audyt. Czyli na zapis kto potrzebował czego. Analiza takich rzeczy może nawet wykryć włamania na konta!
 
 To co chcemy to aby każde skorzystanie z API do pobierania danych zawierało informacje o tym _co_, _kto_ i jeszcze gdzie w kodzie zostało wywołane.
 */

func audit<A,B>(capability: @escaping (A) -> B?,
                what: String,
                who: String,
                file: StaticString = #file,
                line: Int = #line ) -> (A) -> B? {
    return { (a: A) -> B? in
        print("Audit(\(file) : \(line)): `\(who)` is using `\(what)` with `\(a)`")
        
        return a
                |> logWithMessage("Audit(\(file) : \(line)): Input argument")
                |> capability
                |> logWithMessage("Audit(\(file) : \(line)): Result")
    }
}

/*:
 Funkcja przyjmuje _capability_ `(A) -> B?` i ostatecznie zwraca funkcje typu `(A) -> B?`. Dodatkowe argumenty zostawiają ślad użycia. Nawet do poziomu pliku oraz linijki tego pliku!
 */

/// When getting user some logs are generated.
let auditedGetUserCapability = audit(
    capability: capabilityGetUser,
    what: "Getting user",
    who: "Ed"
)

/*:
 Parametr _who_ może być dowolnie ustawiony. Aktualny ID użytkownika, sesja, cokolwiek. Argumenty o pliku i linijce mogą być fajną wskazówką do poszukania odpowiedniego miejsca w kodzie gdzie to zostało zdefiniowane.
 
 W _ruchu_ taka _zdolność_ wygląda tak:
 */

run("📚 I can see the audited version") {
    auditedGetUserCapability(1)
    auditedGetUserCapability(2)
    auditedGetUserCapability(3)
}

/*:

 Jeżeli _Ed_ chce to może przekazać tą zdolność dla Johna. Powiedzmy, że w ten sposób deleguje część obowiązków razem z narzędziami do ich wykonania.
 
 */

let edDelegatesGettingUserCapabilityToJohn = audit(
    capability: auditedGetUserCapability,
    what: "Getting user using Ed capa",
    who: "John"
)

run("🏄🏽‍♂️ Audit the audited version 😳") {
    edDelegatesGettingUserCapabilityToJohn(1)
    edDelegatesGettingUserCapabilityToJohn(2)
    edDelegatesGettingUserCapabilityToJohn(3)
}

/*:
 W konsoli pojawiają się oba _audyty_. Oryginalnie jest używana _zdolność_ przyznana Edwardowi. Natomiast cały łańcuszek jest widoczny.
 
 # Zabieranie zdolności
 
 Gdy dajemy komuś zdolność to ufamy temu komuś, że jej nie będzie nadużywał. Co jednak gdy chciałbym dać ją na chwile? Jak zaimplementować taki system, który w każdej chwili mógłbym kogoś pozbawić tej _zdolności_.
 
 Z pomocą przyjdzie kolejna _zdolność_ do owijania innych zdolności.
 
 */

typealias SideEffect = Void
typealias SideEffectClosure = () -> SideEffect

func makeRevokableCapability<A,B>(from cap: @escaping (A) -> B?) -> ( (A) -> B?, SideEffectClosure ) {
    // internal flag
    var isValid = true

    // run capability as long as `isValid`
    func wrappedCap(_ a: A) -> B? { isValid ? cap(a) : .none }

    // sets flag to false
    func revokeCap() { isValid = false }

    return (wrappedCap, revokeCap)
}

/*:
 Funkcja zwraca parę funkcji. Pierwsza w parze to udekorowana zdolność. Druga to funkcja, która zmienia wewnętrzny stan i sprawia, że _oryginalna_ zdolność przestaje być dostępna. Sam mechanizm jest identyczny z tym, który widzieliśmy przy ograniczaniu ilości wywołań.
 */

let (secureGetUser1, revokeGetUser1) = makeRevokableCapability(from: capabilityGetUser)
let (secureGetUser2, revokeGetUser2) = makeRevokableCapability(from: capabilityGetUser)

run("🚕 Can bake sec right inside") {
    
    print(
        "-- Getting users:",
        secureGetUser1(1) as Any,
        secureGetUser2(1) as Any,
        separator: "\n"
    )

    print("-- Revoking getting user 2")
    revokeGetUser2()

    print(
        "-- Using capabilities 1 & 2 to get users:",
        secureGetUser1(1) as Any,
        secureGetUser2(1) as Any,
        secureGetUser1(2) as Any,
        secureGetUser2(2) as Any,
        secureGetUser1(42) as Any,
        secureGetUser2(42) as Any,
        separator: "\n"
    )

    print("-- Revoking getting user 1")
    revokeGetUser1()

    print(
        "-- Checking if user 1 can get user:",
        secureGetUser1(1) as Any,
        secureGetUser1(2) as Any,
        secureGetUser1(42) as Any,
        separator: "\n"
    )
}

/*:

 Jasno widać po logach w konsoli, że mamy osobno kontrolę nad tym jak długo ktoś może wołać dany kawałek kodu. W tym przykładzie do momentu aż nie zostanie wywołana metoda zabierająca zdolność. Jednak to nie musi działać w ten sposób. To sprawdzenie może polegać na dacie (od 8 do 16 metoda działa) czy innym zasobie dostępnym z dowolnego miejsca.
 
 Istotne w tym podejściu jest to, że każda taka funkcja transformująca zajmowała się jednym aspektem danego zachowania. Oryginalnie pobieranie danych o użytkowniku. Następnie dodanie jakiegoś logowania, audytowania i na końcu bezpieczeństwa. Gdyby trzeba było ten kod zapisać w jednej metodzie to implementacja była by mniej czytelna. Ciężej by było powiedzieć, że tak na prawdę to chodzi o pobieranie danych o użytkowniku.
 
 W ten sposób mamy jasno określone aspekty kodu (logika biznesowa, bezpieczeństwo, logowanie). Możemy ich użyć ponownie w innych miejscach. Patrząc też na poszczególne metody łatwiej jest powiedzieć czym się zajmują. To prawda, że jak się dużo takich złoży do kupy to całość już nie jest taka prosta do ogarnięcia. Jednak to wynika już z natury problemu. Pobieranie danych użytkownika, które jest bezpieczne i audytowalne jest z natury trudniejsze i bardziej skomplikowane od po prostu pobierania użytkownika. Ten kod nie dorzuca (lub minimalnie) dodatkowego skomplikowania.
 
 # Traceability
 
 W bardzo prostu sposób możemy zainteresować się kolejnym aspektem uruchomionego kodu. Tym razem pod lupę weźmiemy czas jaki jest potrzebny do wykonania wstrzykniętej _zdolności_.
 
 */

/// Returns capability that is timed.
func profileAspect<A,B>(_ capability: @escaping (A) -> B) -> (A) -> B {
    return { (a: A) in
        let start = Date()
        let result = capability(a)
        let elapsedTime = Date().timeIntervalSince(start)

        print("Call did take: \(elapsedTime)")
        return result
    }
}

/*:
  Zwracamy zdolność, która mierzy czas między startem a zakończeniem działania oryginalnej capability.
 */

/// Timed get user capability.
let profiledGetUser = capabilityGetUser |> profileAspect

run("⌚️ It's easy to profile also.") {
    profiledGetUser(1)
    profiledGetUser(2)
    profiledGetUser(3)
}

/*:
 Gdy już się _załapie_ ten schemat to transformowanie takich capabilities staje się trywialne. Poniżej capability sprawiające, że kod się wykona z losowym opóźnieniem od 1 do 3 sekund.
 */

func slowDown<A,B>(_ cap: @escaping (A) -> B) -> (A) -> B {
    return { (a: A) -> B in
        sleep(UInt32.random(in: 1...3))
        return cap(a)
    }
}

/*:

 Zbudowanie capability, które jest spowolnione i _profilowane_ pod aspektem czasu wykonania, przy użyciu operatorów jest trywialne.
 
 > `>>>` komponuje dwie funkcje a `|>` przekazuje argument do funkcji; wszystkie operatory są wyjaśnione w [serii funkcyjnej](https://www.youtube.com/playlist?list=PLk_5PV9LrXp-R6TM86MxqlihQSu_ZIhUk),

 */

/// get user capability that is lowed down and timed
let slowProfiledGetUser = capabilityGetUser |> slowDown >>> profileAspect

tb("🐌 Slow is fun") {
    print(
        [1,2,42] <^> slowProfiledGetUser
    )
}

/*:
  Rezultat jest bardzo ciekawy. Mamy wypisany czas potrzebny na każde wywołanie, całkowity czas całego bloku oraz na wyjściu dostajemy tablicę z wynikami.
 
 Kolejna trywialna transformacja to dodawanie _cache-owania_. Za każdym razem gdy wołamy spowolnione capability musimy zapłacić _karę_ związaną z czekaniem (strzał do sieci lub dużo pracy). W łatwy sposób można dodać _zdolność_ do sprawdzania czy już nie było takiego odpytania i jak tak wykorzystać poprzednią odpowiedź.
 */

/// Has internal cache for optimization of getting user requests.
func cachedCapability<A: Hashable, B>(_ capability: @escaping (A) -> B) -> (A) -> B {
    
    // internal cache
    var cache = [A: B]()

    return { (a: A) -> B in
        
        // check if has cached vale and if true return it
        if let cached = cache[a] { return cached }

        // did not have a returned value so...
        // run capability
        let result = capability(a)
        
        // store result in cache
        cache[a] = result
        
        // return the result
        return result
    }
}

/*:
 Implementacja w tym momencie nie powinna nikogo zaskakiwać. Dla każdego capability tworzymy osobny cache (czy można zrobić jeden dla wszystkich? czy powinno się to zrobić?). Jeżeli mamy wartość w cache to ją zwracamy. Jeżeli nie to uruchamiamy przekazaną capability, zapamiętujemy wynik i go zwracamy.
 */

/// cached slow profile getter
let cachedSlowProfile = cachedCapability( slowProfiledGetUser )

/*:
 Bez cache-owania każdy strzał sprawia, że płacimy koszt związany z czasem dostępu do zasobu. Gdy mamy jednak cache to kolejne wywołania powinny być _darmowe_ (w porównaniu do oryginalnego kosztu tak małe, że w ogólnym rozrachunku nie istotne).
 */

tb("🏎 Slow cached is fast") {
    print(cachedSlowProfile(1) as Any)
    print(cachedSlowProfile(1) as Any)
    print(cachedSlowProfile(1) as Any)
    print(cachedSlowProfile(1) as Any)
    print(cachedSlowProfile(1) as Any)
    print(cachedSlowProfile(1) as Any)
    print(cachedSlowProfile(1) as Any)
    print(cachedSlowProfile(1) as Any)
    print(cachedSlowProfile(1) as Any)
    print(cachedSlowProfile(1) as Any)
    print(cachedSlowProfile(1) as Any)
}

/*:
 Analizując wynik w terminalu widać, że oryginalne (przekazane) capability wykonało się tylko raz. Nawet widać ile trwało wykonanie tego kodu. Kolejne wywołania nie były potrzebne ponieważ już mieliśmy rezultat tego zawołania. Cały blok wywołał się praktycznie _w tym samym czasie_ co pierwsze wywołanie.
 
 Już prawie na koniec rzućmy okiem jeszcze raz jak te wszystkie zabawki można ze sobą połączyć:
 */

run("🤩🧸🏓🛹🎲🎳🎮 More fun when you use all of the toys") {
    _ = [1,2,42]
        .map(
            audit(capability: capabilityGetUser |> slowDown >>> profileAspect,
                        what: "Getting user",
                        who: "John")
    )
}

/*:
 Przyznaje tekstu jest bardzo dużo na wyjściu. Co nie zmienia faktu, że dodatnie tak dokładnej instrumentacji jest trywialne.
 
 # Debounce
 
 Debounce to bardzo użyteczne narzędzie, które szczególnie przydaje się przy handlowaniu z wejściami na UI. Search bar którego wejście służy do odpytania API o jakieś dane. Nie ma sensu wykonywać strzał po każdym wpisaniu znaczka ponieważ użytkownik może być w trakcie wpisywania dłuższej frazy. Lepiej _odbić_ te pierwsze i dopiero jak przestanie pisać to wykonać ten strzał.
 
 Podobnie testerzy mają bardzo niespokojne ręce i tapią na przyciski jak szaleni 😉 Dobre jest czasem sprawić aby wielokrotne naduszanie jednego przycisku nie powodowało miliona akcji.
 
 Musimy troszeczkę zaczekać na wykonanie kodu w placu zabaw. Aby nie zakończył działania z ostatnią linijką ustawię flagę aby mimo wszystko _biegł dalej_.
 */


import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 Capability przyjmie czas jaki ma zaczekać zanim wywoła akcje. Kolejkę na której ma zostać wywołana akcja oraz sama akcja jaka ma być wywołana.
 */

func debounced(
    delay: TimeInterval,
    queue: DispatchQueue = .main,
    action: @escaping SideEffectClosure) -> SideEffectClosure {

    var workItem: DispatchWorkItem?

    return {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: action)
        queue.asyncAfter(deadline: .now() + delay, execute: workItem!)
    }
}

/*:
 Wewnętrzny stan składa się z opcjonalnej instancji `DispatchWorkItem`. Służy ona do przechowania bloku jaki ma być wykonany. Instancje tej klasy mają metodę `cancel`, która pozwala anulować wywołanie bloku.
 
 Gdy ktoś wywoła to capability na samym początku jest anulowane _stare_ zadanie. Za pierwszym razem jest tam `.none` więc nic się nie wykona. Następnie tworzona jest instancja ``DispatchWorkItem` z blokiem do wykonania. Kolejka ma specjalną metodę, która pozwala na określenie kiedy ma zostać uruchomiony dany kawałek kodu.
 */


let debouncedPrint = debounced(delay: 1.0) {
    print("💝💝💝 Action performed!", Date())
}

run("💝 Multiple prints but just one time call!") {
    debouncedPrint()
    debouncedPrint()
    debouncedPrint()
    debouncedPrint()
    debouncedPrint()
    print("Finished calling prints...", Date())
}

/*:
 Wywołanie pod rząd tej samej metody ma na celu symulowanie użytkownika, który cały czas coś pisze lub nadusza. Kod zaczekał wyznaczony czas i dopiero wykonał blok.
 
 # Podsumowanie
 
 Ilość przykładów pokazuje jak ten sam mechanizm można wykorzystać do różnych rzeczy. Kontrolować różne aspekty oprogramowania. Do tego składać je ze sobą w bardziej rozbudowane. Prawdą jest, że czasem jest to łatwiejsze a czasem trudniejsze. Jednak w życiu mamy do rozwiązania prostsze zadania a czasem nieco mniej.
 
 Mam nadzieję, że każdy coś dla siebie z tego wyciągnie i postara się spojrzeć na zwykłą funkcję jak na coś więcej jak _nazwany kawałek kodu_.
 
 
 # Linki
 
 Główną inspiracją do tego placu zabaw jest ta prezentacja: [Designing with capabilities for fun and profit - Scott Wlaschin](https://vimeo.com/162209391). Generalnie polecam poszukać inne bo są bardzo ciekawe i pozwalają spojrzeć na znane tematy z zupełnie innej perspektywy.
 
 */

/// Stops playground running after some time
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    print("⏲ waited long enough... stoping playground", Date())
    PlaygroundPage.current.finishExecution()
}

//: [Next](@next)

print("🏁")
