//
//  AppDelegate.swift
//  MetroRechka
//
//  Created by Слава Платонов on 06.03.2022.
//

import UIKit
import Rechka
import YandexMapsMobile
import YandexMobileMetrica

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Rechka.registerFonts()
        YMKMapKit.setApiKey("dee693d0-349d-4757-9a94-e9a237abb930")
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: "4f023df8-11f2-4db6-bf1d-9e9855736a8f")
        YMMYandexMetrica.activate(with: configuration!)
        
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
