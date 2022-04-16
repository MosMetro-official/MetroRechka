//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import CoreNetwork
import SwiftDate

public struct R_ShortTrip {
    public let id: Int
    public let dateStart: Date
    
    init?(data: CoreNetwork.JSON) {
        guard let id = data["id"].int,
              let startDate = data["dateTimeStart"].stringValue.toISODate(nil, region: nil)?.date
        else { return nil }
        self.id = id
        self.dateStart = startDate.date
    }
    
}
