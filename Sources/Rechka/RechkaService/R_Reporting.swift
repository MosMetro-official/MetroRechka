//
//  File.swift
//  
//
//  Created by guseyn on 12.04.2022.
//

import Foundation
import YandexMobileMetrica



final class R_ReportService {
    static let shared = R_ReportService()
    
    enum ErrorIndetifier: String {
        case networkError = "river.network"
        case stateError = "river.stateError"
        
    }
    
    func report(error identifier: ErrorIndetifier, message: String, parameters: [String: Any]) {
        let error = YMMError(
            identifier: identifier.rawValue,
            message: message,
            parameters: parameters,
            backtrace: Thread.callStackReturnAddresses,
            underlyingError: nil)
        YMMYandexMetrica.report(error: error, onFailure: nil)
    }
    
    func report(event name: String, parameters: [String: Any]) {
        YMMYandexMetrica.reportEvent(name, parameters: parameters, onFailure: { (error) in
            print("DID FAIL REPORT EVENT: %@", name)
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
}
