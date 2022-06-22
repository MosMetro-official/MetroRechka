//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import MMCoreNetworkCallbacks

struct R_Tariff: Hashable, Codable {
    
    enum TariffType: Int, Codable {
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
    var place: Int?
    
    
    
//
//    init?(data: JSON) {
//        guard let id = data["id"].string, let type = TariffType(rawValue: data["type"].intValue) else { return nil }
//        self.id = id
//        self.type = type
//        self.name = data["name"].stringValue
//        self.price = data["price"].doubleValue
//        let info = data["info"].stringValue
//        self.info = info.isEmpty ? nil : info
//        self.isWithoutPlace = data["isWithoutPlace"].boolValue
//    }
    
    func toAdditionService() -> R_AdditionService {
        return .init(id: self.id, name_ru: name, name_en: name, type: type.rawValue, price: price)
    }
    
}
