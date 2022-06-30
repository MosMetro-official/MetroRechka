//
//  File.swift
//  
//
//  Created by guseyn on 09.04.2022.
//

import Foundation


struct R_AdditionService: Equatable, Hashable, Encodable {
    let id: String
    let name_ru: String
    let name_en: String
    let type: Int
    let price: Double
    var count = 0
    
    private var totalPrice: Double {
        return price * Double(count)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name_ru = "name"
        case name_en = "nameEn"
        case price = "pricePerOne"
        case type
        case count
        case priceTotal
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name_ru, forKey: .name_ru)
        try container.encode(name_en, forKey: .name_en)
        try container.encode(type, forKey: .type)
        try container.encode(price, forKey: .price)
        try container.encode(count, forKey: .count)
        try container.encode(totalPrice, forKey: .priceTotal)
    }
    
    
}
