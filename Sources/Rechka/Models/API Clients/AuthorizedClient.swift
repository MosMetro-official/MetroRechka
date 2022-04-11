//
//  File.swift
//  
//
//  Created by guseyn on 02.04.2022.
//

import Foundation
import CoreNetwork

extension APIClient {
    public static var authorizedClient : APIClient {
        return APIClient(host: "river.brndev.ru", delegate: SecureApiClientDelegate(), httpProtocol: .HTTPS, configuration: .default)
    }
}

internal final class SecureApiClientDelegate : APIClientDelegate {
    
    private var attempts = 0
    
    func client(_ client: APIClient, willSendRequest request: inout URLRequest) {
        request.appendAuthHeaders()
        
    }
    
    func client(_ client: APIClient, initialRequest: Request, didReceiveInvalidResponse response: HTTPURLResponse, data: Data?) async throws -> Response {
        if response.statusCode == 401 {
            guard let networkDelegate = Rechka.shared.networkDelegate else {
                throw fatalError("Вы не реализовали делегат работы с авторизацией")
            }

            if try await networkDelegate.refreshToken() {
                attempts += 1
                if attempts > 2 {
                    attempts = 0
                    throw APIError.genericError("Что-то пошло не так")
                }
                return try await client.send(initialRequest)
            } else {
                throw APIError.badRequest
            }
         
        } else {
            if let data = data {
                let json = CoreNetwork.JSON(data)
                print("🥰 ERROR - \(json)")
                let message = json["error"]["message"].stringValue
                throw APIError.genericError(message)
            }
            throw APIError.unacceptableStatusCode(response.statusCode)
        }
    }
}
