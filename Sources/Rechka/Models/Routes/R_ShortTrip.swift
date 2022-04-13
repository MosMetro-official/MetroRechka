//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import CoreNetwork
import SwiftDate

struct R_ShortTrip {
    let id: Int
    let freePlaceCount: Int
    let price: Double
    let dateStart: Date
    
    init?(data: CoreNetwork.JSON) {
        guard let id = data["id"].int,
              let freePlaceCount = data["freePlaceCount"].int,
              let startDate = data["dateTimeStart"].stringValue.toISODate(nil, region: nil)?.date,
              let price = data["ticketPrice"].double
        else { return nil }
        self.id = id
        self.freePlaceCount = freePlaceCount
        self.price = price
        self.dateStart = startDate.date
    }
    
}
