
import UIKit
import SwiftUI
import GridView
import Prelude

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        window?.rootViewController =
            gridViewController(
                gridViewModel(
                    Array(repeating: nop, count: 9),
                    \.rawValue >>> String.init // //toIntIndex >>> String.init
                ).right!
            )

        window?.makeKeyAndVisible()
    }
}

