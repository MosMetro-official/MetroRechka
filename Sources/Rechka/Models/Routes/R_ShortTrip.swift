//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import MMCoreNetwork
import SwiftDate

public struct R_ShortTrip {
    public let id: Int
    public let dateStart: Date
    
    init?(data: JSON) {
        guard let id = data["id"].int,
              let startDate = data["dateTimeStart"].stringValue.toISODate(nil, region: .UTC)?.date
        else { return nil }
        self.id = id
        self.dateStart = startDate.date
    }
    
}
