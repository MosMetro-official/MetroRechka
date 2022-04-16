//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import CoreNetwork

// MARK: - Station
public struct R_Station : _RiverStation {
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
    
    
    init(data: CoreNetwork.JSON) {
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
        self.galleries = data["galleries"].arrayValue.map { R_Gallery(data: $0) }
        self.onSelect = { }
    }
    
}

extension R_Station {
    
    public static func getStations(completion: @escaping (Result<[R_Station],APIError>) -> Void) {
        let client = APIClient.unauthorizedClient
        client.send(.GET(path: "/api/references/v1/stationsFrom", query: nil)) { result in
            switch result {
            case .success(let response):
                let json = JSON(response.data)
                guard let jsonArray = json["data"].array else {
                    completion(.failure(.badMapping))
                    return
                }
                let stations = jsonArray.map { R_Station(data: $0) }
                completion(.success(stations))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
    
}
