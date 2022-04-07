//
//  File.swift
//  
//
//  Created by guseyn on 04.04.2022.
//

import Foundation
import CoreNetwork
import SwiftDate

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
    let operationHash: String
    
    
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
        self.operationHash = data["operationHash"].stringValue
    }
    
    
}

extension RiverOperationTicket {
    
//    public func calculateRefund() async throws -> RiverTicketRefund {
//
//    }
    
    private func documentExist(path: String) -> URL? {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(path)
            if fileManager.fileExists(atPath: fileURL.path) {
                return fileURL
            } else {
                return nil
            }
            
        } catch {
            print(error)
            return nil
        }
    }
    
    private func saveDocument(path: String, data: Data) throws -> URL {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(path)
            fileManager.createFile(atPath: fileURL.path, contents: data)
            
            return fileURL
        } catch {
            throw error
        }
    }
    
    func docPath() -> String {
        return "Маршрутная квитанция электронного билета" + " \(dateTimeStart.toFormat("d MMMM HH:mm", locale: Locales.russian))" + " \(id)" + ".pdf"
    }
    
    public func getDocumentURL() async throws -> URL {
        if let filePath = documentExist(path: self.docPath()) {
            return filePath
        } else {
            do {
                let client = APIClient.authorizedClient
                let response = try await client.send(
                    .GET(
                        path: "/api/tickets/v1/\(self.id)/blank",
                        query: ["operationHash": self.operationHash])
                )
                guard let data = response.data as? Data else {
                    throw APIError.badData
                }
                let fileURL = try saveDocument(path: self.docPath(), data: data)
                return fileURL
                
            } catch {
                throw error
            }
        }
    }
        
        
    
}
