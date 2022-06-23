//
//  File.swift
//  
//
//  Created by guseyn on 28.03.2022.
//

import Foundation
import MMCoreNetworkAsync
import SwiftDate




public struct R_RouteResponse: Decodable {
    let items: [R_Route]
    let page: Int
    let totalPages: Int
    let totalElements: Int
    
    enum CodingKeys: String, CodingKey {
        case items
        case page
        case totalPages
        case totalElements
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = try values.decode([R_Route].self, forKey: .items)
        page = try values.decode(Int.self, forKey: .page)
        totalPages = try values.decode(Int.self, forKey: .totalPages)
        totalElements = try values.decode(Int.self, forKey: .totalElements)
    }
    
}

public struct R_Point: Decodable {
    public let latitude: Double
    public let longitude: Double
    public let position: Int
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
        case position
    }
}

public struct R_Route: Decodable {
    public let id: Int
    public let name: String
    public let minPrice: Int
    public let time: Int
    public let distance: Int
    
    // tags
    public let tags: [String]
    
    // polyline
    public let polyline: [R_Point]
    
    // stations
    public let stations: [R_Station]
    
    // galleries
    public let galleries: [R_Gallery]
    
    // trips short
    public let shortTrips: [R_ShortTrip]
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case minPrice
        case time
        case distance
        case tags
        case polyline
        case stations
        case galleries = "galleries"
        case shortTrips = "trips"
    }
    
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        minPrice = try values.decode(Int.self, forKey: .minPrice)
        time = try values.decode(Int.self, forKey: .time)
        distance = try values.decode(Int.self, forKey: .distance)
        tags = try values.decode([String].self, forKey: .tags)
        polyline = try values.decode([R_Point].self, forKey: .polyline)
        stations = try values.decode([R_Station].self, forKey: .stations)
        galleries =  try values.decode([R_Gallery].self, forKey: .galleries)
        shortTrips = try values.decode([R_ShortTrip].self, forKey: .shortTrips)
    }
    
    
    
}

extension R_Route {
    
    static func getRoute(by id: Int) async throws -> R_Route {
        let client = APIClient.unauthorizedClient
        let response = try await client.send(.GET(path: "/api/routes/v1/\(id)"))
        let decoder = JSONDecoder()
        return try decoder.decode(R_BaseResponse<R_Route>.self, from: response.data).data
    }
    
    
    
    static func getRoutes(page: Int, size: Int, stationID: Int? = nil, date: Date?, tags: [String]) async throws -> R_RouteResponse {
        let client = APIClient.unauthorizedClient
        var query: [String: String] = [
            "size": "\(size)",
            "page": "\(page)"
        ]
        
        if let stationID = stationID {
            query.updateValue("\(stationID)", forKey: "stationId")
        }
        
        if !tags.isEmpty {
            query.updateValue(tags.joined(separator: ","), forKey: "tags")
        }
        
        if let date = date {
            query.updateValue(date.toFormat("YYYY-MM-dd", locale: nil), forKey: "date")
        }
        
        let response = try await client.send(.GET(path: "/api/routes/v1", query: query))
        return try JSONDecoder().decode(R_BaseResponse<R_RouteResponse>.self, from: response.data).data
        
    }
}



