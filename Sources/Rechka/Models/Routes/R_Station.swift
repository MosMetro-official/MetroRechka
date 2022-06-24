//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import MMCoreNetworkAsync

// MARK: - Station
public struct R_Station : _RiverStation, Decodable {
    public  let id: Int
    public let name: String
    public let cityID: Int
    public let cityName, regionName: String
    public let countryID: Int
    public let countryName, countryISO: String
    public let latitude, longitude: Double
    public let position: Int?
    public let galleries: [R_Gallery]
    public var onSelect : (() -> Void)
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case cityID = "cityId"
        case cityName
        case regionName
        case countryID = "countryId"
        case countryName
        case countryISO
        case latitude = "lat"
        case longitude = "lon"
        case position
        case galleries
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        cityID = try values.decode(Int.self, forKey: .cityID)
        cityName = try values.decode(String.self, forKey: .cityName)
        regionName = try values.decode(String.self, forKey: .regionName)
        countryID = try values.decode(Int.self, forKey: .countryID)
        countryName = try values.decode(String.self, forKey: .countryName)
        countryISO = try values.decode(String.self, forKey: .countryISO)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)
        position = try values.decodeIfPresent(Int.self, forKey: .position)
        galleries = try values.decode([R_Gallery].self, forKey: .galleries)
        onSelect = {}
    }
    
    

    
}

extension R_Station {
    
    public static func getStations() async throws -> [R_Station] {
        let client = APIClient.unauthorizedClient
        let response = try await client.send(  .GET(path: "/api/references/v1/stationsFrom"))
        return try JSONDecoder().decode(R_BaseResponse<[R_Station]>.self, from: response.data).data
        
    }
    
    
}
