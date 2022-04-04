//
//  File.swift
//  
//
//  Created by guseyn on 04.04.2022.
//

import Foundation
import CoreNetwork

struct RiverTicketRefund {
    let ticketID: Int
    let refundPrice: Double
    let refundDate: Date // MSK timezone
    let totalPriceRefund: Double
    
    init?(data: CoreNetwork.JSON) {
        guard let ticketID = data["id"].int, let refundDate = data["dateTimeRefund"].stringValue.toDate()?.date else { return nil }
        self.ticketID = ticketID
        self.refundPrice = data["ticketPriceRefund"].doubleValue
        self.refundDate  = refundDate
        self.totalPriceRefund = data["totalPriceRefund"].doubleValue
    }
    
}

struct RiverOperationTicket {
    
    enum Status: Int {
        case payed = 1 // билет продан
        case returnedByCarrier = 2 // Билет продан, после продажи возвращен перевозчиком
        case booked = 3 // Билет находится во временной брони
        case returnedByAgent = 4 // Билет продан, после продажи возвращен агентом.
    }
    
    let id: Int
    let routeName: String 
    let price: Double
    let status: Status
    let refund: RiverTicketRefund?
    let stationStart: RiverStation?
    let stationEnd: RiverStation?
    let place: Int
    let dateTimeStart: Date
    let dateTimeEnd: Date
    
    
    init?(data: CoreNetwork.JSON) {
        guard let id = data["id"].int,
              let dateTimeStart = data["dateTimeStart"].stringValue.toDate()?.date,
              let dateTimeEnd = data["dateTimeEnd"].stringValue.toDate()?.date,
        let status = Status(rawValue: data["status"].intValue) else { return nil }
        self.id = id
        self.routeName = data["routeName"].stringValue
        self.price = data["ticketPrice"].doubleValue
        self.status = status
        self.refund = RiverTicketRefund(data: data["ticketRefund"])
        self.stationStart = RiverStation(data: data["stationStart"])
        self.stationEnd = RiverStation(data: data["stationEnd"])
        self.place = data["position"].intValue
        self.dateTimeStart = dateTimeStart
        self.dateTimeEnd = dateTimeEnd
    }
    
    
}
