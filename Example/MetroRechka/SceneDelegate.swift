//
//  SceneDelegate.swift
//  MetroRechka
//
//  Created by Слава Платонов on 06.03.2022.
//

import UIKit
import Rechka


class Dummy: RechkaNetworkDelegate {
    func refreshToken(completion: @escaping (Bool) -> Void) {
        completion(false)
    }
    
}



class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    let dummy = Dummy()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        Rechka.shared.isMapsAvailable = true
        Rechka.shared.isMapsRoutesAvailable = true
        Rechka.shared.delegate = self
        Rechka.shared.networkDelegate = dummy
        
            
            
        window?.rootViewController = Rechka.shared.showRechkaFlow()
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let first = URLContexts.first?.url {
            print(first)
            if first.absoluteString.contains(Rechka.shared.returnURL) {
                NotificationCenter.default.post(name: .riverPaymentSuccess,
                                                object: nil,
                                                userInfo: nil)
            }
            
            if first.absoluteString.contains(Rechka.shared.failURL){
                NotificationCenter.default.post(name: .riverPaymentFailure,
                                                object: nil,
                                                userInfo: nil)
            }
        }
    }
}

extension SceneDelegate : RechkaMapDelegate {
    
    func rechkaRouteController(with route: R_Route) -> R_RouteLineController {
        return RouteMapController(route: route)
    }
    
    func rechkaStationsController() -> R_StationsController {
        return MapViewController()
    }
    
    
 
    
}
