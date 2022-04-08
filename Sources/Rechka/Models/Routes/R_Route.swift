//
//  File.swift
//  
//
//  Created by guseyn on 28.03.2022.
//

import Foundation
import CoreNetwork
import SwiftDate

extension APIClient {
    
    public static var unauthorizedClient : APIClient {
        return APIClient(host: "river.brndev.ru")
    }
    
}


struct R_RouteResponse {
    let items: [R_Route]
    let page: Int
    let totalPages: Int
    let totalElements: Int
}

struct R_Point {
    let latitude: Double
    let longitude: Double
    let position: Int
    
    init(data: CoreNetwork.JSON) {
        self.latitude = data["lat"].doubleValue
        self.longitude = data["lon"].doubleValue
        self.position = data["position"].intValue
    }
}

struct R_Route {
    let id: Int
    let name: String
    let minPrice: Int
    let time: Int
    let distance: Int
    
    // tags
    let tags: [String]
    let schedule: [Date]
    
    // polyline
    let polyline: [R_Point]
    
    // stations
    let stations: [R_Station]
    
    // galleries
    let galleries: [R_Gallery]
    
    // trips short
    let shortTrips: [R_ShortTrip]
    
    
    
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
        self.schedule = []
        self.shortTrips = data["trips"].arrayValue.compactMap { R_ShortTrip(data: $0) }
        
    }
    
    
}

extension R_Route {
    
    static func getRoute(by id: Int) async throws -> R_Route {
        let client = APIClient.unauthorizedClient
        do {
            let response = try await client.send(
                .GET(
                    path: "/api/routes/v1/\(id)",
                    query: nil)
            )
            let json = CoreNetwork.JSON(response.data)
            let route = R_Route(data: json["data"])
            return route
        } catch {
            guard let err = error as? APIError else { throw error }
            print(err)
            throw err
        }
    }
    
    static func getRoutes() async throws -> R_RouteResponse {
        let client = APIClient.unauthorizedClient
        do {
            let response = try await client.send(
                .GET(
                    path: "/api/routes/v1",
                    query: nil)
            )
            let json = CoreNetwork.JSON(response.data)
            guard let routesArray = json["data"]["items"].array,
                  let page = json["data"]["page"].int,
                  let totalPages = json["data"]["totalPages"].int,
                  let totalElements = json["data"]["totalElements"].int else { throw APIError.noHTTPResponse }
            let routes = routesArray.map { R_Route(data: $0) }
            return .init(items: routes, page: page, totalPages: totalPages, totalElements: totalElements)
        } catch {
            guard let err = error as? APIError else { throw error }
            print(err)
            throw err
        }
        
    }
}



