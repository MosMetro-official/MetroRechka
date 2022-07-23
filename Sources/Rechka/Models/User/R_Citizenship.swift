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
        case id
        case name
        case isonumeric
        case isoalpha2
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: R_Citizenship.EncodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        isonumeric = try values.decode(String.self, forKey: .isonumeric)
        isoalpha2 = try values.decode(String.self, forKey: .isoalpha2)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(isonumeric, forKey: .isonumeric)
        try container.encode(isoalpha2, forKey: .isoalpha2)
    }
    
    static func getCitizenships() async throws -> [R_Citizenship] {
        let client = APIClient.unauthorizedClient
        let response = try await client.send(.GET(path: "/api/references/v1/citizenship"))
        return try JSONDecoder().decode(R_BaseResponse<[R_Citizenship]>.self, from: response.data).data
    }
}
