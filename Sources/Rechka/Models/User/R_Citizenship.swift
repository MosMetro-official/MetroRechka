//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import MMCoreNetworkAsync


struct R_Citizenship: Equatable, Codable {
    let id: Int
    let name: String
    let isonumeric: String
    let isoalpha2: String
    
    private enum EncodingKeys: String, CodingKey {
        case id = "citizenshipId"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(id, forKey: .id)
    }
    
    static func getCitizenships() async throws -> [R_Citizenship] {
        let client = APIClient.unauthorizedClient
        let response = try await client.send(.GET(path: "/api/references/v1/citizenship"))
        return try JSONDecoder().decode(R_BaseResponse<[R_Citizenship]>.self, from: response.data).data
    }
}
