//
//  File.swift
//  
//
//  Created by guseyn on 11.04.2022.
//

import Foundation
import CoreNetwork

extension APIClient {
    
    public static var unauthorizedClient : APIClient {
        return APIClient(host: "river.brndev.ru", delegate: BasicApiClientDelegate(), httpProtocol: .HTTPS, configuration: .default)
    }
    
}



internal final class BasicApiClientDelegate : APIClientDelegate {
    
    
    func client(_ client: APIClient, willSendRequest request: inout URLRequest) {
        request.appendBasicHeaders()
        
    }
    
    func client(_ client: APIClient, initialRequest: Request, didReceiveInvalidResponse response: HTTPURLResponse, data: Data?) async throws -> Response {
        
        if let data = data {
            let json = CoreNetwork.JSON(data)
            print("🥰 ERROR - \(json)")
            let message = json["error"]["message"].stringValue
            R_ReportService.shared.report(error: .networkError, message: message, parameters: [:])
            throw APIError.genericError(message)
        }
        R_ReportService.shared.report(error: .networkError, message: "Статус код \(response.statusCode)", parameters: [:])
        throw APIError.unacceptableStatusCode(response.statusCode)
        
    }
}
