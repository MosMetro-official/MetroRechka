//
//  AppDelegate.swift
//  MetroRechka
//
//  Created by Слава Платонов on 06.03.2022.
//

import UIKit
import Rechka
import YandexMapsMobile

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Rechka.registerFonts()
        YMKMapKit.setApiKey("dee693d0-349d-4757-9a94-e9a237abb930")
        if let files = try? FileManager.default.contentsOfDirectory(atPath: fontBundle.bundlePath ){
            for file in files {
                print(file)
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
