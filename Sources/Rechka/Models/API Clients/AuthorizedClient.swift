//
//  File.swift
//  
//
//  Created by guseyn on 02.04.2022.
//

import Foundation
import MMCoreNetworkAsync

extension APIClient {
    public static var authorizedClient : APIClient {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let serializer = Serializer(decoder: decoder, encoder: encoder)

        return APIClient(host: Rechka.shared.APIHost, interceptor: SecureAPIClientInterceptor(), httpProtocol: .HTTPS, configuration: .default, serializer: serializer)
    }
}


internal final class SecureAPIClientInterceptor: APIClientInterceptor {
    func client(_ client: APIClient, initialRequest: Request, didReceiveInvalidResponse response: HTTPURLResponse, data: Data?) async -> RetryPolicy {
        if response.statusCode == 401 {
            guard let networkDelegate = Rechka.shared.networkDelegate else {
                fatalError("Не реализован механизм обновления токена")
            }
            do {
                try await networkDelegate.refreshToken()
                return .shouldRetry
            } catch {
                return .doNotRetryWith(.badRequest)
            }
        }
        return .doNotRetry
    }
    
    
    private var attempts = 0
    
    public func client(_ client: APIClient, willSendRequest request: inout URLRequest) {
        request.appendAuthHeaders()
    }
    
//    public func client(_ client: APIClient, initialRequest: Request, didReceiveInvalidResponse response: HTTPURLResponse, data: Data?, completion: @escaping (RetryPolicy) -> Void) {
//        if response.statusCode == 401 {
//            guard let networkDelegate = Rechka.shared.networkDelegate else {
//                fatalError("Вы не реализовали делегат работы с авторизацией")
//            }
//            networkDelegate.refreshToken { result in
//
//                if result {
//                    completion(.shouldRetry)
//                    return
//                } else {
//                    completion(.doNotRetry)
//                    return
//                }
//            }
//
//        } else {
//            if let data = data {
//                let json = JSON(data)
//                print("🥰 ERROR - \(json)")
//                let message = json["error"]["message"].stringValue
//                R_ReportService.shared.report(error: .networkError, message: message, parameters: [:])
//                completion(.doNotRetryWith(.genericError(message)))
//                return
//            }
//            R_ReportService.shared.report(error: .networkError, message: "Статус код \(response.statusCode)", parameters: [:])
//            completion(.doNotRetryWith(.unacceptableStatusCode(response.statusCode)))
//            return
//        }
//    }
}

