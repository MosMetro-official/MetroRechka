//
//  File.swift
//  
//
//  Created by guseyn on 04.04.2022.
//

import Foundation
import MMCoreNetworkAsync
import SwiftDate

enum RechkaOrderStatus: Int, Decodable {
    case success = 1
    case canceled = 2
    case booked = 3
}

struct RiverOperation: Decodable {
    let id: Int
    var internalOrderID: Int = 0 {
        didSet {
            self.tickets = tickets.map { RiverOperationTicket(from: $0, parentOrderID: internalOrderID) }
        }
    }
    let status: RechkaOrderStatus
    let timeLeftToCancel: Int // seconds
    let orderDate: Date // MSK timezone
    let hash: String
    var tickets: [RiverOperationTicket]
    
    var totalPrice: Double {
        return tickets.reduce(0, { $0 + $1.price })
    }
    
    var routeName: String {
        guard let firstTicket = tickets.first, let stationStart = firstTicket.stationStart, let stationEnd = firstTicket.stationEnd else { return "Экскурсия"}
        return "\(stationStart.name) → \(stationEnd.name)"
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case status
        case timeLeftToCancel
        case orderDate = "dateTimeOrder"
        case hash
        case tickets
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.status = try container.decode(RechkaOrderStatus.self, forKey: .status)
        self.orderDate = try container.decode(Date.self, forKey: .orderDate)
        self.timeLeftToCancel = try container.decode(Int.self, forKey: .timeLeftToCancel)
        self.hash = try container.decode(String.self, forKey: .hash)
        self.tickets = try container.decode([RiverOperationTicket].self, forKey: .tickets)
    }
    
    
}
