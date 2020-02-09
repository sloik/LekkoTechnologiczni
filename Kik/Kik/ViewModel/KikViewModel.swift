//
//
//import Foundation
//
//protocol KikViewModelDelegate {
//    func showWinner(grid: String)
//    func showTie(grid: String)
//}
//
//struct KikViewModel {
//    private var model = KikModel()
//    var delegate: KikViewModelDelegate?
//
//    var grid: String {
//        model
//            .grid
//            .map(model.lineToSymbols(_:)) // .X, .O, .none
//            .map{ symbols in
//                symbols
//                    .map { $0.rawValue }      // "X", "O", "-"
//                    .joined(separator: " ") } // "X O -"
//            .joined(separator: "\n")
//    }
//}
//
//extension KikViewModel {
//    func title(for index: Int) -> String {
//        model.title(for: index)
//    }
//
//    mutating func didTapElement(_ index: Int) {
//        switch model.didTapElement(index) {
//        case .winner:
//            delegate?.showWinner(grid: grid)
//        case .tie:
//            delegate?.showTie(grid: grid)
//        case .playing:
//            break
//        }
//    }
//
//    mutating func resetGame() {
//        model.resetGame()
//    }
//}
