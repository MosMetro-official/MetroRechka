//
//  File.swift
//  
//
//  Created by guseyn on 04.04.2022.
//

import Foundation
import CoreNetwork
import SwiftDate


struct RiverOperation {
    let id: Int
    let status: Status
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
    
    
    enum Status: Int {
        case success = 1
        case canceled = 2
        case booked = 3
    }
    
    init?(data: CoreNetwork.JSON) {
        guard
            let id = data["id"].int,
            let status = Status(rawValue: data["status"].intValue),
            let orderDate = data["dateTimeOrder"].stringValue.toDate()?.date,
            let tickets = data["tickets"].array else { return nil }
        self.id = id
        self.status = status
        self.timeLeftToCancel = data["timeLeftToCancel"].intValue
        self.hash = data["hash"].stringValue
        self.orderDate = orderDate
        self.tickets = tickets.compactMap { RiverOperationTicket(data: $0) }
    }
    
}
