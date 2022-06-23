//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import MMCoreNetworkAsync


struct R_Citizenship: Equatable, Decodable {
    let id: Int
    let name: String
    let isonumeric: String
    let isoalpha2: String
    
    static func getCitizenships() async throws -> [R_Citizenship] {
        let client = APIClient.unauthorizedClient
        let response = try await client.send(.GET(path: "/api/references/v1/citizenship"))
        return try JSONDecoder().decode(R_BaseResponse<[R_Citizenship]>.self, from: response.data).data
    }
}
