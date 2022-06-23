//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import MMCoreNetworkAsync


struct R_Trip: Decodable {
    let id: Int
    let name: String
    let distance: Int?
    let freePlaceCount: Int
    let buyPlaceCountMax: Int
    let dateStart: Date
    let dateEnd: Date
    let vehicle: R_Vehicle?
    let ticketPrintedRequired: Bool?
    let tariffs: [R_Tariff]?
    let personalDataRequired: Bool?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "routeName"
        case distance
        case freePlaceCount
        case buyPlaceCountMax
        case dateStart = "dateTimeStart"
        case dateEnd = "dateTimeEnd"
        case vehicle
        case ticketPrintedRequired
        case tariffs
        case personalDataRequired
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        distance = try values.decodeIfPresent(Int.self, forKey: .distance)
        freePlaceCount = try values.decode(Int.self, forKey: .freePlaceCount)
        buyPlaceCountMax = try values.decode(Int.self, forKey: .buyPlaceCountMax)
        
        let dateStartStr = try values.decode(String.self, forKey: .dateStart)
        let dateEndStr = try values.decode(String.self, forKey: .dateEnd)
        guard let _dateStart = dateStartStr.toISODate(nil, region: .UTC)?.date, let _dateEnd = dateEndStr.toISODate(nil, region: .UTC)?.date else {
            throw APIError.badMapping
        }
        dateStart = _dateStart
        dateEnd = _dateEnd
        vehicle = try? values.decodeIfPresent(R_Vehicle.self, forKey: .vehicle)
        ticketPrintedRequired = try? values.decodeIfPresent(Bool.self, forKey: .ticketPrintedRequired)
        tariffs = try? values.decodeIfPresent([R_Tariff].self, forKey: .tariffs)
        personalDataRequired = try? values.decodeIfPresent(Bool.self, forKey: .personalDataRequired)
    }
    
//    init?(data: JSON) {
//        guard let id = data["id"].int,
//              let name = data["routeName"].string,
//              let startDate = data["dateTimeStart"].stringValue.toISODate(nil, region: .UTC)?.date,
//              let endDate = data["dateTimeEnd"].stringValue.toISODate(nil, region: .UTC)?.date
//        else { return nil }
//
//        self.id = id
//        self.name = name
//        self.distance = data["distance"].intValue
//        self.freePlaceCount = data["freePlaceCount"].intValue
//        self.buyPlaceCountMax = data["buyPlaceCountMax"].intValue
//        self.dateStart = startDate
//        self.dateEnd = endDate
//        self.vehicle = nil
//        self.ticketPrintedRequired = data["ticketPrintedRequired"].bool
//        self.tarrifs = data["tariffs"].array?.compactMap { R_Tariff(data: $0) }
//        self.personalDataRequired = data["personalDataRequired"].bool
//
//    }
    
}



extension R_Trip {
    
    func getFreePlaces() async throws -> [Int] {
        let client = APIClient.unauthorizedClient
        let response = try await client.send(.GET(path: "/api/trips/v1/\(id)/placesAvailability"), debug: true)
        return try JSONDecoder().decode(R_BaseResponse<[Int]>.self, from: response.data).data
        
        
//        client.send(.GET(path: "/api/trips/v1/\(id)/placesAvailability", query: nil)) { result in
//            switch result {
//            case .success(let response):
//                let json = JSON(response.data)
//                guard let array = json["data"].array else {
//                    completion(.failure(.badMapping))
//                    return
//                }
//                let places = array.compactMap { $0.int }
//                completion(.success(places))
//                return
//            case .failure(let err):
//                completion(.failure(err))
//                return
//            }
//        }
    }
    
    static func book(with users: [R_User], tripID: Int, completion: @escaping (Result<RiverOrder, APIError>) -> Void) {
        
//        let tickets: [[String:Any]] = users.map { user in
//            return user.createBodyItem()
//        }
//
//        let body: [String: Any] = [
//            "id": tripID,
//            "returnUrl": Rechka.shared.returnURL,
//            "failUrl": Rechka.shared.failURL,
//            "tickets": tickets
//        ]
//        print(body)
//        let client = APIClient.authorizedClient
//
//        client.send(.POST(path: "/api/orders/v1/booking", body: body, contentType: .json)) { result in
//            switch result {
//
//            case .success(let response):
//                let json = JSON(response.data)
//                guard let order = RiverOrder(data: json["data"]) else {
//                    completion(.failure(.badMapping))
//                    return
//                }
//                completion(.success(order))
//                return
//            case .failure(let error):
//                completion(.failure(error))
//                return
//            }
//        }
        completion(.failure(.badMapping))
        return
        
    }
    
    static func get(by id: Int) async throws -> R_Trip  {
        let client = APIClient.unauthorizedClient
        let response = try await client.send(.GET(
            path: "/api/trips/v1/\(id)",
            query: nil))
        return try JSONDecoder().decode(R_BaseResponse<R_Trip>.self, from: response.data).data
    }
    
}
