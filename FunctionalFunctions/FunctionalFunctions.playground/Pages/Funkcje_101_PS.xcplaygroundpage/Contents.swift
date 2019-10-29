//: [Previous](@previous)

/*:
We wcześniejszym odcinku powiedziałem, że funkcji zapisanej jak niżej nie można wywołać ponieważ brakuje nam do niej nazwy/referencji.
 */

print( { (i: Int) in i - 1 } )

/*:
Nie jest to do końca prawda, ponieważ możemy wywołać tą funkcję w miejscu jej zdefiniowania przekazując do niej od razu wymagane parametry.
 */

print( { (i: Int) in i - 1 }(42) )
print( { (i: Int, j: Int) in i + j }(40, 2) )

/*:
Nie wspomniałem o tym sposobie ponieważ nie występuje zbyt często. A jeżeli już to jedynie jako blok który służy do utworzenia i skonfigurowania instancji jakiegoś obiektu.
 */

import UIKit

let label: UILabel = {
    let label = UILabel()
    label.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
    label.text = "Lorem ipsum"
    label.backgroundColor = .red
    label.textColor = .white
    label.textAlignment = .center
    return label
}()

type(of: label)
label

/*:
Jest to dokładnie ta sama składnia jak wcześniej. Blok/funkcja która jest zdefiniowana wyżej ma typ

 `() -> UILabel`

 Czyli nie musimy przekazywać żadnych argumentów a w zamian dostaniemy instancję `UILabel`.
 */

//: [Next](@next)
