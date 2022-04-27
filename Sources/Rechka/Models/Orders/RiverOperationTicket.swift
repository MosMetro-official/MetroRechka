//
//  File.swift
//  
//
//  Created by guseyn on 04.04.2022.
//

import Foundation
import MMCoreNetwork
import SwiftDate

struct RiverTicketRefund {
    let ticketID: Int
    let refundPrice: Double
    let refundDate: Date? // MSK timezone
    let totalPriceRefund: Double
    let additionRefunds: [R_OperationAdditionServiceRefund]
    
    init?(data: JSON) {
        guard let ticketID = data["id"].int else { return nil }
        self.ticketID = ticketID
        
        self.refundPrice = data["ticketPriceRefund"].doubleValue
        self.refundDate  = data["dateTimeRefund"].stringValue.toISODate(nil, region: .UTC)?.date
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
    
    init?(data: JSON) {
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
        self.date = data["dateTimeRefund"].stringValue.toISODate(nil, region: .UTC)?.date
    }
    
}

struct R_OperationAdditionService {
    let id: String
    let pricePerOne: Double
    let name: String
    let count: Int
    let totalPrice: Double
    let type: Int
    
    init?(data: JSON) {
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
    
    
    init?(data: JSON, parentOrderID: Int) {
        guard let id = data["id"].int,
              let dateTimeStart = data["dateTimeStart"].stringValue.toISODate(nil, region: .UTC)?.date,
              let dateTimeEnd = data["dateTimeEnd"].stringValue.toISODate(nil, region: .UTC)?.date,
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
    
    public func confirmRefund(completion: @escaping (Result<Void, APIError>) -> Void) {
        
        let client = APIClient.authorizedClient
        client.send(.POST(path: "/api/tickets/v1/\(self.id)/order/\(self.parentOrderID)/refund",
                          body: nil,
                          contentType: .json)) { result in
            switch result {
                
            case .success(_):
                completion(.success(()))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
       
    }
    
    public func calculateRefund(completion: @escaping (Result<RiverTicketRefund,APIError>) -> Void) {
        let client = APIClient.authorizedClient
        let path = "/api/tickets/v1/\(self.id)/order/\(self.parentOrderID)/refundAmount"
        client.send(.GET(path: path, query: nil)) { result in
            switch result {
            case .success(let response):
                let json = JSON(response.data)
                guard let refund = RiverTicketRefund(data: json["data"]) else {
                    completion(.failure(.badMapping))
                    return
                }
                completion(.success(refund))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
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
    
    private func saveDocument(path: String, data: Data) -> URL? {
        let fileManager = FileManager.default
        guard let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false) else { return nil }
        let fileURL = documentDirectory.appendingPathComponent(path)
        fileManager.createFile(atPath: fileURL.path, contents: data)
        
        return fileURL
        
        
    }
    
    func docPath() -> String {
        return "Маршрутная квитанция электронного билета" + " \(dateTimeStart.toFormat("d MMMM HH:mm", locale: Locales.russian))" + " \(id)" + ".pdf"
    }
    
    public func getDocumentURL(completion: @escaping (Result<URL,APIError>) -> Void) {
        if let filePath = documentExist(path: self.docPath()) {
            completion(.success(filePath))
            return
        } else {
            let client = APIClient.authorizedClient
            let path = "/api/tickets/v1/\(self.id)/blank"
            let query = ["operationHash": self.operationHash]
            client.send(.GET(path: path, query: query)) { result in
                switch result {
                case .success(let response):
                    guard let data = response.data as? Data else {
                        completion(.failure(.badData))
                        return
                    }
                    guard let fileURL = saveDocument(path: self.docPath(), data: data) else {
                        completion(.failure(.badData))
                        return
                    }
                    completion(.success(fileURL))
                    return
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
        }
    }
        
        
    
}
