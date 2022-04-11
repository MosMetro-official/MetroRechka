//
//  File.swift
//  
//
//  Created by guseyn on 04.04.2022.
//

import Foundation
import CoreNetwork

struct RiverOrder {
    let id: Int
    /// payment url
    let url: String
    
    /// important – UTC time
    let createdDate: Date
    let operation: RiverOperation
    
    init?(data: CoreNetwork.JSON) {
        guard
            let id = data["id"].int,
            let url = data["formUrl"].string,
            let operation = RiverOperation(data: data["operation"], internalOrderID: id),
            let createdDate = data["createdDate"].stringValue.toDate()?.date else { return nil }
        self.id = id
        self.url = url
        self.operation = operation
        self.createdDate = createdDate
    }
}



extension RiverOrder {
    
    func cancelBooking() async throws {
        if case .booked = self.operation.status {
            let client = APIClient.authorizedClient
            do {
                let response = try await client.send(
                    .POST(path: "/api/orders/v1/\(self.id)/cancel",
                          body: nil,
                          contentType: .json)
                )
                let json = CoreNetwork.JSON(response.data)
                if let success = json["success"].bool, success {
                    print("successfully cancelled order")
                } else {
                    throw APIError.genericError("Произошила ошибка при отмене бронирования")
                }
            } catch {
                guard let err = error as? APIError else { throw error }
                print(err)
                throw err
            }
            
            
        } else {
            throw APIError.genericError("Вы не можете произвести отмену этого бронирования")
        }
    }
    
    static func get(by id: Int) async throws -> RiverOrder {
        let client = APIClient.authorizedClient
        do {
            let response = try await client.send(
                .GET(
                    path: "/api/orders/v1/\(id)",
                    query: nil)
            )
            let json = CoreNetwork.JSON(response.data)
            guard let order = RiverOrder(data: json["data"]) else {
                throw APIError.badData
            }
            return order
        } catch {
            guard let err = error as? APIError else { throw error }
            print(err)
            throw err
        }
    }
}
