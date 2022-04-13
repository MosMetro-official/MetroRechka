//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import CoreNetwork


struct R_Trip {
    let id: Int
    let name: String
    let distance: Int
    let freePlaceCount: Int
    let buyPlaceCountMax: Int
    let dateStart: Date
    let dateEnd: Date
    let vehicle: R_Vehicle?
    let ticketPrintedRequired: Bool?
    let tarrifs: [R_Tariff]?
    let personalDataRequired: Bool?
    
    
    init?(data: CoreNetwork.JSON) {
        guard let id = data["id"].int,
              let name = data["routeName"].string,
              let startDate = data["dateTimeStart"].stringValue.toISODate(nil, region: nil)?.date,
              let endDate = data["dateTimeEnd"].stringValue.toISODate(nil, region: nil)?.date
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
        self.tarrifs = data["tariffs"].array?.compactMap { R_Tariff(data: $0) }
        self.personalDataRequired = data["personalDataRequired"].bool
        
    }
    
}

extension R_Trip {
    
    func getFreePlaces() async throws -> [Int] {
        let client = APIClient.unauthorizedClient
        do {
            let response = try await client.send(
                .GET(
                    path: "/api/trips/v1/\(id)/placesAvailability",
                    query: nil)
            )
            let json = CoreNetwork.JSON(response.data)
            guard let array = json["data"].array else {
                throw APIError.badData
            }
            return array.compactMap { $0.int }
        } catch {
            guard let err = error as? APIError else { throw error }
            print(err)
            throw err
        }
    }
    
    static func book(with users: [R_User], tripID: Int) async throws -> RiverOrder {
        
        let tickets: [[String:Any]] = users.map { user in
            return user.createBodyItem()
        }
        
        let body: [String: Any] = [
            "id": tripID,
            "returnUrl": Rechka.shared.returnURL,
            "failUrl": Rechka.shared.failURL,
            "tickets": tickets
        ]
        let client = APIClient.authorizedClient
    
        
        do {
            let bookingResponse = try await client.send(.POST(
                path: "/api/orders/v1/booking",
                body: body,
                contentType: .json)
            )
            let json = CoreNetwork.JSON(bookingResponse.data)
            guard let order = RiverOrder(data: json["data"]) else {
                throw APIError.badData
            }
            print(order)
            return order
        } catch {
            guard let err = error as? APIError else { throw error }
            print(err)
            throw err
        }
    }
    
    static func get(by id: Int) async throws -> R_Trip {
        let client = APIClient.unauthorizedClient
        do {
            let response = try await client.send(
                .GET(
                    path: "/api/trips/v1/\(id)",
                    query: nil)
            )
            let json = CoreNetwork.JSON(response.data)
            guard let trip = R_Trip(data: json["data"]) else {
                throw APIError.badData
            }
            return trip
        } catch {
            guard let err = error as? APIError else { throw error }
            print(err)
            throw err
        }
    }
    
}
