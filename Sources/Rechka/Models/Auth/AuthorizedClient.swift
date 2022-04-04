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

final class SecureApiClientDelegate : APIClientDelegate {
    
    
    
    func client(_ client: APIClient, willSendRequest request: inout URLRequest) {
        request.appendBasicHeaders()
    }
    
    func client(_ client: APIClient, initialRequest: Request, didReceiveInvalidResponse response: HTTPURLResponse, data: Data?) async throws -> Response {
        if response.statusCode == 401 {
            guard let networkDelegate = Rechka.shared.networkDelegate else {
                throw fatalError("Вы не реализовали делегат работы с авторизацией")
            }

            if try await networkDelegate.refreshToken() {
                return try await client.send(initialRequest)
            } else {
                throw APIError.badRequest
            }
         
        } else {
            if let data = data {
                let json = CoreNetwork.JSON(data)
                print("🥰 ERROR - \(json)")
                //throw APIError.cabinetError(.init(json: json["error"]))
                throw APIError.badRequest
            }
            throw APIError.unacceptableStatusCode(response.statusCode)
        }
    }
}
