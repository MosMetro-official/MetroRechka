//
//  File.swift
//  
//
//  Created by guseyn on 28.03.2022.
//

import Foundation
import SwiftyJSON
import CoreNetwork
import SwiftDate

extension APIClient {
    
    public static var unauthorizedClient : APIClient {
        return APIClient(host: "river.brndev.ru")
    }
}

struct RiverRouteResponse {
    let items: [RiverRoute]
    let page: Int
    let totalPages: Int
    let totalElements: Int
}

struct RiverPoint {
    let latitude: Double
    let longitude: Double
    let position: Int
    
    init(data: SwiftyJSON.JSON) {
        self.latitude = data["lat"].doubleValue
        self.longitude = data["lon"].doubleValue
        self.position = data["position"].intValue
    }
}


// MARK: - Vehicle
struct RiverVehicle {
    let name: String?
    let number: String?
    let placeCount: String?
    let airConditioning: Bool?
    let tv: Bool?
    
    
}

// MARK: - RiverTariff

struct RiverTariff {
    
    enum TariffType: Int {
        case base = 1
        case `default` = 2
        case luggage = 3
        case good = 4
        case additional = 5
    }
    
    let id: String
    let type: TariffType
    let name: String
    let price: Double
    let info: String?
    let isWithoutPlace: Bool
    
    init?(data: SwiftyJSON.JSON) {
        guard let id = data["id"].string, let type = TariffType(rawValue: data["type"].intValue) else { return nil }
        self.id = id
        self.type = type
        self.name = data["name"].stringValue
        self.price = data["price"].doubleValue
        let info = data["info"].stringValue
        self.info = info.isEmpty ? nil : info
        self.isWithoutPlace = data["isWithoutPlace"].boolValue
    }
    
    
}



// MARK: - Trip

struct RiverShortTrip {
    let id: Int
    let freePlaceCount: Int
    let price: Double
    let dateStart: Date
    
    init?(data: SwiftyJSON.JSON) {
        guard let id = data["id"].int,
              let freePlaceCount = data["freePlaceCount"].int,
              let startDate = data["dateTimeStart"].stringValue.toDate()?.date,
              let price = data["ticketPrice"].double
        else { return nil }
        self.id = id
        self.freePlaceCount = freePlaceCount
        self.price = price
        self.dateStart = startDate
    }
    
}


struct RiverTrip {
    let id: Int
    let name: String
    let distance: Int
    let freePlaceCount: Int
    let buyPlaceCountMax: Int
    let dateStart: Date
    let dateEnd: Date
    let vehicle: Vehicle?
    let ticketPrintedRequired: Bool?
    let tarrifs: [RiverTariff]?
    
    
    init?(data: SwiftyJSON.JSON) {
        guard let id = data["id"].int,
                let name = data["routeName"].string,
              let startDate = data["dateTimeStart"].stringValue.toDate()?.date,
              let endDate = data["dateTimeEnd"].stringValue.toDate()?.date
        else { return nil }
        
        self.id = id
        self.name = name
        self.distance = data["distance"].intValue
        self.freePlaceCount = data["freePlaceCount"].intValue
        self.buyPlaceCountMax = data["buyPlaceCountMax"].intValue
        self.dateStart = startDate
        self.dateEnd = endDate
        self.vehicle = nil
        self.ticketPrintedRequired = data["ticketPrintedRequired"].bool
        self.tarrifs = data["tariffs"].array?.compactMap { RiverTariff(data: $0) }
    }
    
}

// MARK: - Gallery
struct RiverGallery {
    let id: Int
    let title: String
    let galleryDescription: String?
    let urls: [String]
    
    init(data: SwiftyJSON.JSON) {
        self.id = data["id"].intValue
        self.title = data["title"].stringValue
        self.galleryDescription = data["description"].string
        self.urls = data["urls"].arrayValue.compactMap {  $0.string }
    }
    
}

// MARK: - Station
struct RiverStation {
    let id: Int
    let name: String
    let cityID: Int
    let cityName, regionName: String
    let countryID: Int
    let countryName, countryISO: String
    let latitude, longitude: Double
    let position: Int?
    let galleries: [RiverGallery]
    
    
    init(data: SwiftyJSON.JSON) {
        self.id = data["id"].intValue
        self.name = data["name"].stringValue
        self.cityID = data["cityId"].intValue
        self.cityName = data["cityName"].stringValue
        self.regionName = data["regionName"].stringValue
        self.latitude = data["lat"].doubleValue
        self.longitude = data["lon"].doubleValue
        self.position = data["position"].int
        self.countryID = data["countryId"].intValue
        self.countryName = data["countryName"].stringValue
        self.countryISO = data["countryISO"].stringValue
        self.galleries = data["galleries"].arrayValue.map { RiverGallery(data: $0) }
        
    }
    
}

struct RiverRoute {
    let id: Int
    let name: String
    let minPrice: Int
    let time: Int
    let distance: Int
    
    // tags
    let tags: [String]
    let schedule: [Date]
    
    // polyline
    let polyline: [RiverPoint]
    
    // stations
    let stations: [RiverStation]
    
    // galleries
    let galleries: [RiverGallery]
    
    // trips short
    let shortTrips: [RiverShortTrip]
    
    
    
    init(data: SwiftyJSON.JSON) {
        self.id = data["id"].intValue
        self.name = data["name"].stringValue
        self.minPrice = data["minPrice"].intValue
        self.time = data["time"].intValue
        self.distance = data["distance"].intValue
        self.tags = data["tags"].arrayValue.compactMap { $0.string }
        self.polyline = data["polyline"].arrayValue.map { RiverPoint(data: $0)  }
        self.stations = data["stations"].arrayValue.map { RiverStation(data: $0) }
        self.galleries = data["galleries"].arrayValue.map { RiverGallery(data: $0) }
        self.schedule = []
        self.shortTrips = data["trips"].arrayValue.compactMap { RiverShortTrip(data: $0) }
        
    }
    
    
}

extension RiverRoute {
    
    static func getRoute(by id: Int) async throws -> RiverRoute {
        let client = APIClient.unauthorizedClient
        do {
            let response = try await client.send(
                .GET(
                    path: "/api/routes/v1/\(id)",
                    query: nil)
            )
            let json = SwiftyJSON.JSON(response.data)
            let route = RiverRoute(data: json["data"])
            return route
        } catch {
            guard let err = error as? APIError else { throw error }
            print(err)
            throw err
        }
    }
    
    static func getRoutes() async throws -> RiverRouteResponse {
        let client = APIClient.unauthorizedClient
        do {
            let response = try await client.send(
                .GET(
                    path: "/api/routes/v1",
                    query: nil)
            )
            let json = SwiftyJSON.JSON(response.data)
            guard let routesArray = json["data"]["items"].array,
                  let page = json["data"]["page"].int,
                  let totalPages = json["data"]["totalPages"].int,
                  let totalElements = json["data"]["totalElements"].int else { throw APIError.noHTTPResponse }
            let routes = routesArray.map { RiverRoute(data: $0) }
            return .init(items: routes, page: page, totalPages: totalPages, totalElements: totalElements)
        } catch {
            guard let err = error as? APIError else { throw error }
            print(err)
            throw err
        }
        
    }
}
