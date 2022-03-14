//
//  SceneDelegate.swift
//  MetroRechka
//
//  Created by Слава Платонов on 06.03.2022.
//

import UIKit
import Rechka

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = Rechka.showRechkaFlow()
        window?.makeKeyAndVisible()
    }
}

