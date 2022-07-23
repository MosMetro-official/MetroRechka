//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import MMCoreNetworkAsync

struct R_Document: Equatable, Codable {
    let id: Int
    let name: String
    let inputMask: String
    let regularMask: String
    let useNumpadOnly: Bool
    let nationalityUse: Int
    let pictureIndex: Int
    let exampleNumber: String
    var cardIdentityNumber: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case inputMask
        case regularMask
        case useNumpadOnly
        case nationalityUse
        case pictureIndex
        case exampleNumber
        case cardIdentityNumber
    }
    
    static func getDocs(by id: Int) async throws -> [R_Document] {
        let client = APIClient.unauthorizedClient
        let response = try await client.send(.GET(path: "/api/references/v1/idCards/\(id)"))
        return try JSONDecoder().decode(R_BaseResponse<[R_Document]>.self, from: response.data).data
    }
}
