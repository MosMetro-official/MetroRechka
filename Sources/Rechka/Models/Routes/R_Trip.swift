//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import MMCoreNetwork


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
    
    
    init?(data: JSON) {
        guard let id = data["id"].int,
              let name = data["routeName"].string,
              let startDate = data["dateTimeStart"].stringValue.toISODate(nil, region: .UTC)?.date,
              let endDate = data["dateTimeEnd"].stringValue.toISODate(nil, region: .UTC)?.date
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
    
    func getFreePlaces(completion: @escaping (Result<[Int],APIError>) -> Void) {
        let client = APIClient.unauthorizedClient
        client.send(.GET(path: "/api/trips/v1/\(id)/placesAvailability", query: nil)) { result in
            switch result {
            case .success(let response):
                let json = JSON(response.data)
                guard let array = json["data"].array else {
                    completion(.failure(.badMapping))
                    return
                }
                let places = array.compactMap { $0.int }
                completion(.success(places))
                return
            case .failure(let err):
                completion(.failure(err))
                return
            }
        }
    }
    
    static func book(with users: [R_User], tripID: Int, completion: @escaping (Result<RiverOrder, APIError>) -> Void) {
        
        let tickets: [[String:Any]] = users.map { user in
            return user.createBodyItem()
        }
        
        let body: [String: Any] = [
            "id": tripID,
            "returnUrl": Rechka.shared.returnURL,
            "failUrl": Rechka.shared.failURL,
            "tickets": tickets
        ]
        print(body)
        let client = APIClient.authorizedClient
        
        client.send(.POST(path: "/api/orders/v1/booking", body: body, contentType: .json)) { result in
            switch result {
                
            case .success(let response):
                let json = JSON(response.data)
                guard let order = RiverOrder(data: json["data"]) else {
                    completion(.failure(.badMapping))
                    return
                }
                completion(.success(order))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
        
    }
    
    static func get(by id: Int, completion: @escaping (Result<R_Trip,APIError>) -> Void)  {
        let client = APIClient.unauthorizedClient
        client.send(.GET(
            path: "/api/trips/v1/\(id)",
            query: nil)) { result in
                switch result {
                case .success(let response):
                    let json = JSON(response.data)
                    guard let trip = R_Trip(data: json["data"]) else {
                        completion(.failure(.badMapping))
                        return
                    }
                    completion(.success(trip))
                    return
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
                
                
            }
    }
    
}
