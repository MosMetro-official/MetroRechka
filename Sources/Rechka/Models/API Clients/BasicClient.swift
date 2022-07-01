//
//  File.swift
//  
//
//  Created by guseyn on 11.04.2022.
//

import Foundation

import MMCoreNetworkAsync

extension APIClient {
    
    public static var unauthorizedClient : APIClient {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let serializer = Serializer(decoder: decoder, encoder: encoder)
        return APIClient(host: Rechka.shared.APIHost, interceptor: BasicApiClientInterceptor(), httpProtocol: .HTTPS, configuration: .default, serializer: serializer, debug: true)
    }
    
}



internal final class BasicApiClientInterceptor : APIClientInterceptor {
    
    func client(_ client: APIClient, willSendRequest request: inout URLRequest) {
        request.appendBasicHeaders()
    }
    
    func client(_ client: APIClient, initialRequest: Request, didReceiveInvalidResponse response: HTTPURLResponse, data: Data?) async -> RetryPolicy {
        if let data = data {
            print(String(data: data, encoding: .utf8))
//            let json = JSON(data)
//            print("🥰 ERROR - \(json)")
//            let message = json["error"]["message"].stringValue
//            R_ReportService.shared.report(error: .networkError, message: message, parameters: [:])
//            return .doNotRetryWith(.genericError(message))
        }
        return .doNotRetry
    }
    

}
