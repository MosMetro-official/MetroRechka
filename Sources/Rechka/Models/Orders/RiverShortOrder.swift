//
//  File.swift
//  
//
//  Created by guseyn on 05.04.2022.
//

import Foundation
import CoreNetwork


struct RechkaHistoryResponse {
    let page: Int
    let totalPages: Int
    let totalElements: Int
    var orders: [RechkaShortOrder]
    
    init?(data: CoreNetwork.JSON) {
        guard let ordersArray = data["items"].array else { return nil }
        self.page = data["page"].intValue
        self.totalPages = data["totalPages"].intValue
        self.totalElements = data["totalElements"].intValue
        self.orders = ordersArray.compactMap { RechkaShortOrder(data: $0) }
    }
    
}

struct RechkaShortOrder {
    let id: Int
    let status: RechkaOrderStatus
    let routeName: String
    let createdDate: Date
    let totalPrice: Double
    
    init?(data: CoreNetwork.JSON) {
        guard let id = data["id"].int,
              let status = RechkaOrderStatus(rawValue: data["status"].intValue),
              let createdDate = data["createdDate"].stringValue.toISODate(nil, region: nil)?.date else { return nil }
        self.id = id
        self.status = status
        self.routeName = data["routeName"].stringValue
        self.createdDate = createdDate
        self.totalPrice = data["totalPrice"].doubleValue
    }
    
}

extension RechkaShortOrder {
    
    static func getOrders(size: Int = 10, page: Int = 0) async throws -> RechkaHistoryResponse {
        let client = APIClient.authorizedClient
        do {
            let query: [String: String] = ["size": "\(size)",
                          "page": "\(page)"]
            
            
            let response = try await client.send(
                .GET(
                    path: "/api/orders/v1/",
                    query: query)
            )
            let json = CoreNetwork.JSON(response.data)
            guard let response = RechkaHistoryResponse(data: json["data"]) else {
                throw APIError.badData
            }
            return response
        } catch {
            guard let err = error as? APIError else { throw error }
            print(err)
            throw err
        }
    }
    
}
