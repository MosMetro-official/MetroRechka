//
//  File.swift
//  
//
//  Created by guseyn on 04.04.2022.
//

import Foundation
import MMCoreNetworkAsync
import SwiftDate

struct RiverTicketRefund: Decodable {
    let ticketID: Int
    let refundPrice: Double
    let refundDate: Date? // MSK timezone
    let totalPriceRefund: Double
    let additionRefunds: [R_OperationAdditionServiceRefund]
    
    private enum CodingKeys: String, CodingKey {
        case ticketID = "id"
        case refundPrice = "ticketPriceRefund"
        case refundDate = "dateTimeRefund"
        case totalPriceRefund = "totalPriceRefund"
        case additionRefunds = "additionServicesRefund"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ticketID = try container.decode(Int.self, forKey: .ticketID)
        self.refundPrice = try container.decode(Double.self, forKey: .refundPrice)
        let stringDate = try container.decodeIfPresent(String.self, forKey: .refundDate)
        guard let date = stringDate?.toISODate(nil, region: .UTC)?.date else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.refundDate], debugDescription: "date cant be parsed"))
        }

        self.refundDate = date
        self.totalPriceRefund = try container.decode(Double.self, forKey: .totalPriceRefund)
        self.additionRefunds = try container.decode([R_OperationAdditionServiceRefund].self, forKey: .additionRefunds)
    }
    
    
}

struct R_OperationAdditionServiceRefund: Decodable {
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
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case nameEn = "nameEn"
        case type
        case pricePerOne
        case count
        case priceTotal
        case pricePerOneRefund
        case priceTotalRefund
        case date = "dateTimeRefund"
    }
    
//    init?(data: JSON) {
//        guard let id = data["id"].string else { return nil }
//        self.id = id
//        self.name = data["name"].stringValue
//        self.nameEn = data["nameEn"].stringValue
//        self.type = data["type"].intValue
//        self.pricePerOne = data["pricePerOne"].doubleValue
//        self.count = data["count"].intValue
//        self.priceTotal = data["priceTotal"].doubleValue
//        self.pricePerOneRefund = data["pricePerOneRefund"].doubleValue
//        self.priceTotalRefund = data["priceTotalRefund"].doubleValue
//        self.date = data["dateTimeRefund"].stringValue.toISODate(nil, region: .UTC)?.date
//    }
    
}

struct R_OperationAdditionService: Decodable {
    let id: String
    let pricePerOne: Double
    let name: String
    let count: Int
    let totalPrice: Double
    let type: Int
    
}

struct RiverOperationTicket {
    
    enum Status: Int, Decodable {
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case routeName
        case price = "ticketPrice"
        case status
        case refund = "ticketRefund"
        case stationStart
        case stationEnd
        case place = "position"
        case dateTimeStart
        case dateTimeEnd
        case operationHash
        case additionServices
    }
    
  
    
   
    
    
    init(from container: KeyedDecodingContainer<CodingKeys>, parentOrderID: Int) throws {
        self.id = try container.decode(Int.self, forKey: .id)
        self.routeName = try container.decode(String.self, forKey: .routeName)
        self.price = try container.decode(Double.self, forKey: .price)
        self.status = try container.decode(Status.self, forKey: .status)
        self.refund = try container.decodeIfPresent(RiverTicketRefund.self, forKey: .refund)
        self.stationStart = try container.decodeIfPresent(R_Station.self, forKey: .stationStart)
        self.stationEnd = try container.decodeIfPresent(R_Station.self, forKey: .stationStart)
        self.place = try container.decode(Int.self, forKey: .place)
        self.dateTimeStart = try container.decode(Date.self, forKey: .dateTimeStart)
        self.dateTimeEnd = try container.decode(Date.self, forKey: .dateTimeEnd)
        self.operationHash = try container.decode(String.self, forKey: .operationHash)
        self.additionServices = try container.decode([R_OperationAdditionService].self, forKey: .additionServices)
        self.parentOrderID = parentOrderID
    }
    
//    init(from decoder: Decoder, parentOrderID: Int) throws {
//        self.parentOrderID = parentOrderID
//        self.init(from: decoder)
//    }
    
//    init?(data: JSON, parentOrderID: Int) {
//        guard let id = data["id"].int,
//              let dateTimeStart = data["dateTimeStart"].stringValue.toISODate(nil, region: .UTC)?.date,
//              let dateTimeEnd = data["dateTimeEnd"].stringValue.toISODate(nil, region: .UTC)?.date,
//        let status = Status(rawValue: data["status"].intValue) else { return nil }
//        self.id = id
//        self.parentOrderID = parentOrderID
//        self.routeName = data["routeName"].stringValue
//        self.price = data["ticketPrice"].doubleValue
//        self.status = status
//        self.refund = RiverTicketRefund(data: data["ticketRefund"])
////        self.stationStart = R_Station(data: data["stationStart"])
////        self.stationEnd = R_Station(data: data["stationEnd"])
//        self.stationStart = nil
//        self.stationEnd = nil
//        self.place = data["position"].intValue
//        self.dateTimeStart = dateTimeStart
//        self.dateTimeEnd = dateTimeEnd
//        self.operationHash = data["operationHash"].stringValue
//        self.additionServices = data["additionServices"].arrayValue.compactMap { R_OperationAdditionService(data: $0) }
//    }
    
    
}

extension RiverOperationTicket {
    
    public func confirmRefund() async throws {
        let client = APIClient.authorizedClient
        try await client.send(.POST(path: "/api/tickets/v1/\(self.id)/order/\(self.parentOrderID)/refund", contentType: .json))
       
    }
    
    public func calculateRefund() async throws -> RiverTicketRefund {
        let client = APIClient.authorizedClient
        let path = "/api/tickets/v1/\(self.id)/order/\(self.parentOrderID)/refundAmount"
        let refund: R_BaseResponse<RiverTicketRefund> = try await client.send(.GET(path: path)).value
        return refund.data
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
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let fileURL = documentDirectory.appendingPathComponent(path)
        fileManager.createFile(atPath: fileURL.path, contents: data)
        return fileURL
        
        
    }
    
    func docPath() -> String {
        return "Маршрутная квитанция электронного билета" + " \(dateTimeStart.toFormat("d MMMM HH:mm", locale: Locales.russian))" + " \(id)" + ".pdf"
    }
    
    public func getDocumentURL() async throws -> URL {
        if let filePath = documentExist(path: self.docPath()) {
            return filePath
        } else {
            let client = APIClient.authorizedClient
            let path = "/api/tickets/v1/\(self.id)/blank"
            let query = ["operationHash": self.operationHash]
            let response = try await client.send(.GET(path: path, query: query))
            let url = try saveDocument(path: self.docPath(), data: response.data)
            return url
        }
    }
        
        
    
}
