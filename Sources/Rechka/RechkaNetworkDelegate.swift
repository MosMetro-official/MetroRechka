//
//  File.swift
//  
//
//  Created by guseyn on 02.04.2022.
//

import Foundation



public protocol RechkaNetworkDelegate: AnyObject {
    
    /// Метод необходим для обновления авторизационного токена. Вы должны реализовать его на своей стороне
    /// - Returns: Результат обновления токена
    func refreshToken() async throws -> Bool
    
}
