//
//  File.swift
//  
//
//  Created by guseyn on 04.04.2022.
//

import Foundation
import CoreNetwork
import SwiftDate

enum RechkaOrderStatus: Int {
    case success = 1
    case canceled = 2
    case booked = 3
}

struct RiverOperation {
    let id: Int
    let internalOrderID: Int
    let status: RechkaOrderStatus
    let timeLeftToCancel: Int // seconds
    let orderDate: Date // MSK timezone
    let hash: String
    let tickets: [RiverOperationTicket]
    
    var totalPrice: Double {
        return tickets.reduce(0, { $0 + $1.price })
    }
    
    var routeName: String {
        guard let firstTicket = tickets.first, let stationStart = firstTicket.stationStart, let stationEnd = firstTicket.stationEnd else { return "Экскурсия"}
        return "\(stationStart.name) → \(stationEnd.name)"
    }
    
    
    
    
    init?(data: CoreNetwork.JSON, internalOrderID: Int) {
        guard
            let id = data["id"].int,
            let status = RechkaOrderStatus(rawValue: data["status"].intValue),
            let orderDate = data["dateTimeOrder"].stringValue.toISODate(nil, region: nil)?.date,
            let tickets = data["tickets"].array else { return nil }
        self.id = id
        self.internalOrderID = internalOrderID
        self.status = status
        self.timeLeftToCancel = data["timeLeftToCancel"].intValue
        self.hash = data["hash"].stringValue
        self.orderDate = orderDate
        self.tickets = tickets.compactMap { RiverOperationTicket(data: $0, parentOrderID: internalOrderID) }
    }
    
}
