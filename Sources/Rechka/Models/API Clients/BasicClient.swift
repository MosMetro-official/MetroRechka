//
//  File.swift
//  
//
//  Created by guseyn on 11.04.2022.
//

import Foundation
import MMCoreNetwork

extension APIClient {
    
    public static var unauthorizedClient : APIClient {
        return APIClient(host: Rechka.shared.APIHost, interceptor: BasicApiClientInterceptor(), httpProtocol: .HTTPS, configuration: .default)
    }
    
}



internal final class BasicApiClientInterceptor : APIClientInterceptor {
    
    func client(_ client: APIClient, willSendRequest request: inout URLRequest) {
        request.appendBasicHeaders()
    }
    
    func client(_ client: APIClient, initialRequest: Request, didReceiveInvalidResponse response: HTTPURLResponse, data: Data?, completion: @escaping (RetryPolicy) -> Void) {
        if let data = data {
            let json = JSON(data)
            print("🥰 ERROR - \(json)")
            let message = json["error"]["message"].stringValue
            R_ReportService.shared.report(error: .networkError, message: message, parameters: [:])
            completion(.doNotRetryWith(.genericError(message)))
            return
        }
        R_ReportService.shared.report(error: .networkError, message: "Статус код \(response.statusCode)", parameters: [:])
        completion(.doNotRetryWith(.unacceptableStatusCode(response.statusCode)))
        return
    }
    

}
