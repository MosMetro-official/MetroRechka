//
//  File.swift
//  
//
//  Created by guseyn on 02.04.2022.
//

import Foundation

extension URLRequest {
        
    enum Headers: String {
        case deviceHeader = "X-DeviceID"
        case sessionHeader = "X-SessionID"
        case contentHeader = "Content-Type"
        case contentLength = "Content-Length"
        case languageHeader = "Accept-Language"
        case userAgentHeader = "User-Agent"
        case apiVariantHeader = "X-API-Variant"
        case applicationHeader = "Application"
        case authorizationHeader = "Authorization"
        
        static var device = deviceHeader.rawValue
        static var length = contentLength.rawValue
        static var session = sessionHeader.rawValue
        static var content = contentHeader.rawValue
        static var language = languageHeader.rawValue
        static var userAgent = userAgentHeader.rawValue
        static var application = applicationHeader.rawValue
        static var authorization = authorizationHeader.rawValue
        static var apiVariant = apiVariantHeader.rawValue
    }
    
    mutating func appendBasicHeaders() {
        self.setValue(Rechka.shared.deviceUUID, forHTTPHeaderField: Headers.deviceHeader.rawValue)
        self.setValue(Rechka.shared.deviceUserAgent, forHTTPHeaderField: Headers.userAgentHeader.rawValue)
        self.setValue(Rechka.shared.language, forHTTPHeaderField: Headers.languageHeader.rawValue)
        if let authToken = Rechka.shared.token {
            self.setValue("Bearer \(authToken)", forHTTPHeaderField: Headers.applicationHeader.rawValue)
            self.setValue("Bearer \(authToken)", forHTTPHeaderField: Headers.authorizationHeader.rawValue)
        }
    }
    
}
