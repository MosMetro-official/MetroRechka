//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import MMCoreNetworkCallbacks
import SwiftDate

public struct R_ShortTrip: Decodable {
    public let id: Int
    public let dateStart: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case dateStart = "dateTimeStart"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        let dateStartStr = try values.decode(String.self, forKey: .dateStart)
        guard let _dateStart = dateStartStr.toISODate(nil, region: .UTC)?.date else {
            throw APIError.badMapping
        }
        dateStart = _dateStart
    }
    

    
}
