//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import CoreNetwork

// MARK: - Station
struct R_Station : _RiverStation {
    let id: Int
    let name: String
    let cityID: Int
    let cityName, regionName: String
    let countryID: Int
    let countryName, countryISO: String
    let latitude, longitude: Double
    let position: Int?
    let galleries: [R_Gallery]
    var onSelect : (() -> Void)
    
    
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
