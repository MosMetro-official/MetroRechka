//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import MMCoreNetworkAsync

struct R_Tariff: Hashable, Codable {
    
    enum TariffType: Int, Codable {
        case base = 1
        case `default` = 2
        case luggage = 3
        case good = 4
        case additional = 5
        
//        private enum CodingKeys: Int, CodingKey {
//            case base = 1
//            case
//        }
    }
    
    let id: String
    let type: TariffType
    let name: String
    let price: Double
    let info: String?
    let isWithoutPlace: Bool
    var place: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
        case price
        case info
        case isWithoutPlace
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        type = try values.decode(TariffType.self, forKey: .type)
        name = try values.decode(String.self, forKey: .name)
        price = try values.decode(Double.self, forKey: .price)
        let _info = try values.decodeIfPresent(String.self, forKey: .info)
        info = _info == "" ? nil : _info
        isWithoutPlace = try values.decode(Bool.self, forKey: .isWithoutPlace)
    }
    
    
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
