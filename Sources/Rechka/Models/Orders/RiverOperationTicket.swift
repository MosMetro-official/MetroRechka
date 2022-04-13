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
    let refundDate: Date? // MSK timezone
    let totalPriceRefund: Double
    let additionRefunds: [R_OperationAdditionServiceRefund]
    
    init?(data: CoreNetwork.JSON) {
        guard let ticketID = data["id"].int else { return nil }
        self.ticketID = ticketID
        
        self.refundPrice = data["ticketPriceRefund"].doubleValue
        self.refundDate  = data["dateTimeRefund"].stringValue.toISODate(nil, region: nil)?.date
        self.totalPriceRefund = data["totalPriceRefund"].doubleValue
        self.additionRefunds = data["additionServicesRefund"].arrayValue.compactMap { R_OperationAdditionServiceRefund(data: $0) }
    }
    
}

struct R_OperationAdditionServiceRefund {
    let id: String
    let name: String
    let nameEn: String
    let type: Int
    let pricePerOne: Double
    let count: Int
    let priceTotal: Double
    let pricePerOneRefund: Double
    let priceTotalRefund: Double
    let date: Date?
    
    init?(data: CoreNetwork.JSON) {
        guard let id = data["id"].string else { return nil }
        self.id = id
        self.name = data["name"].stringValue
        self.nameEn = data["nameEn"].stringValue
        self.type = data["type"].intValue
        self.pricePerOne = data["pricePerOne"].doubleValue
        self.count = data["count"].intValue
        self.priceTotal = data["priceTotal"].doubleValue
        self.pricePerOneRefund = data["pricePerOneRefund"].doubleValue
        self.priceTotalRefund = data["priceTotalRefund"].doubleValue
        self.date = data["dateTimeRefund"].stringValue.toISODate(nil, region: nil)?.date
    }
    
}

struct R_OperationAdditionService {
    let id: String
    let pricePerOne: Double
    let name: String
    let count: Int
    let totalPrice: Double
    let type: Int
    
    init?(data: CoreNetwork.JSON) {
        guard let id = data["id"].string else { return nil }
        self.id = id
        self.pricePerOne = data["pricePerOne"].doubleValue
        self.name = data["name"].stringValue
        self.count = data["count"].intValue
        self.totalPrice = data["priceTotal"].doubleValue
        self.type = data["type"].intValue
    }
}

struct RiverOperationTicket {
    
    enum Status: Int {
        case payed = 1 // билет продан
        case returnedByCarrier = 2 // Билет продан, после продажи возвращен перевозчиком
        case booked = 3 // Билет находится во временной брони
        case returnedByAgent = 4 // Билет продан, после продажи возвращен агентом.
        case returned = 5 // билет возвращен
    }
    
    let id: Int
    let parentOrderID: Int
    let routeName: String 
    let price: Double
    let status: Status
    let refund: RiverTicketRefund?
    let stationStart: R_Station?
    let stationEnd: R_Station?
    let place: Int
    let dateTimeStart: Date
    let dateTimeEnd: Date
    let operationHash: String
    let additionServices: [R_OperationAdditionService]
    
    
    init?(data: CoreNetwork.JSON, parentOrderID: Int) {
        guard let id = data["id"].int,
              let dateTimeStart = data["dateTimeStart"].stringValue.toISODate(nil, region: nil)?.date,
              let dateTimeEnd = data["dateTimeEnd"].stringValue.toISODate(nil, region: nil)?.date,
        let status = Status(rawValue: data["status"].intValue) else { return nil }
        self.id = id
        self.parentOrderID = parentOrderID
        self.routeName = data["routeName"].stringValue
        self.price = data["ticketPrice"].doubleValue
        self.status = status
        self.refund = RiverTicketRefund(data: data["ticketRefund"])
        self.stationStart = R_Station(data: data["stationStart"])
        self.stationEnd = R_Station(data: data["stationEnd"])
        self.place = data["position"].intValue
        self.dateTimeStart = dateTimeStart
        self.dateTimeEnd = dateTimeEnd
        self.operationHash = data["operationHash"].stringValue
        self.additionServices = data["additionServices"].arrayValue.compactMap { R_OperationAdditionService(data: $0) }
    }
    
    
}

extension RiverOperationTicket {
    
    public func confirmRefund() async throws {
        do {
            let client = APIClient.authorizedClient
            let _ = try await client.send(
                .POST(path: "/api/tickets/v1/\(self.id)/order/\(self.parentOrderID)/refund",
                      body: nil,
                      contentType: .json)
            )
            return
        } catch {
            throw error
        }
    }
    
    public func calculateRefund() async throws -> RiverTicketRefund {
        do {
            let client = APIClient.authorizedClient
            let response = try await client.send(
                .GET(
                    path: "/api/tickets/v1/\(self.id)/order/\(self.parentOrderID)/refundAmount",
                    query: nil)
            )
            let json = CoreNetwork.JSON(response.data)
            guard let refund = RiverTicketRefund(data: json["data"]) else {
                throw APIError.badData
            }
            return refund
            
        } catch {
            throw error
        }
    }
    
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
