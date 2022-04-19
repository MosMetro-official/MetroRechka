//
//  File.swift
//  
//
//  Created by guseyn on 28.03.2022.
//

import Foundation
import CoreNetwork
import SwiftDate




public struct R_RouteResponse {
    let items: [R_Route]
    let page: Int
    let totalPages: Int
    let totalElements: Int
}

public struct R_Point {
    public let latitude: Double
    public let longitude: Double
    public let position: Int
    
    init(data: CoreNetwork.JSON) {
        self.latitude = data["lat"].doubleValue
        self.longitude = data["lon"].doubleValue
        self.position = data["position"].intValue
    }
}

public struct R_Route {
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
    
    
    
    init(data: CoreNetwork.JSON) {
        self.id = data["id"].intValue
        self.name = data["name"].stringValue
        self.minPrice = data["minPrice"].intValue
        self.time = data["time"].intValue
        self.distance = data["distance"].intValue
        self.tags = data["tags"].arrayValue.compactMap { $0.string }
        self.polyline = data["polyline"].arrayValue.map { R_Point(data: $0)  }
        self.stations = data["stations"].arrayValue.map { R_Station(data: $0) }
        self.galleries = data["galleries"].arrayValue.map { R_Gallery(data: $0) }
        self.shortTrips = data["trips"].arrayValue.compactMap { R_ShortTrip(data: $0) }
        
    }
    
    
}

extension R_Route {
    
    static func getRoute(by id: Int, completion: @escaping (Result<R_Route,APIError>) -> Void) {
        let client = APIClient.unauthorizedClient
        client.send(.GET(path: "/api/routes/v1/\(id)",query: nil)) { result in
            switch result {
            case .success(let response):
                let json = CoreNetwork.JSON(response.data)
                let route = R_Route(data: json["data"])
                completion(.success(route))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
    static func getRoutes(page: Int, size: Int, stationID: Int? = nil, date: Date?, tags: [String], completion: @escaping (Result<R_RouteResponse,APIError>) -> Void) {
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
        
        client.send(.GET(path: "/api/routes/v1", query: query)) { result in
            switch result {
            case .success(let response):
                let json = CoreNetwork.JSON(response.data)
                guard let routesArray = json["data"]["items"].array,
                      let page = json["data"]["page"].int,
                      let totalPages = json["data"]["totalPages"].int,
                      let totalElements = json["data"]["totalElements"].int else {
                          completion(.failure(.badMapping))
                          return
                      }
                print("😀 total elements array: \(routesArray.count)")
                let routes = routesArray.map { R_Route(data: $0) }
                let routeResponse = R_RouteResponse(items: routes, page: page, totalPages: totalPages, totalElements: totalElements)
                completion(.success(routeResponse))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
        
    }
}



