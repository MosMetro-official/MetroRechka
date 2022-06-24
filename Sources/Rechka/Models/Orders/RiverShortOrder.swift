//
//  File.swift
//  
//
//  Created by guseyn on 05.04.2022.
//

import Foundation
import MMCoreNetworkAsync


struct RechkaHistoryResponse: Decodable {
    let page: Int
    let totalPages: Int
    let totalElements: Int
    var orders: [RechkaShortOrder]
    
    private enum CodingKeys: String, CodingKey {
        case page
        case totalPages
        case totalElements
        case orders = "items"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        page = try values.decode(Int.self, forKey: .page)
        totalPages = try values.decode(Int.self, forKey: .totalPages)
        totalElements = try values.decode(Int.self, forKey: .totalElements)
        orders = try values.decode([RechkaShortOrder].self, forKey: .orders)
    }

    
}

struct RechkaShortOrder: Decodable {
    let id: Int
    private let operation: ShortOrderOperation
    let status: RechkaOrderStatus
    let routeName: String?
    let totalPrice: Double
    
    var operationID: Int {
        return operation.id
    }
    
    var createdDate: Date {
        return operation.dateTimeOrder
    }
    
    
    struct ShortOrderOperation: Decodable {
        let id: Int
        let dateTimeOrder: Date
        
        private enum CodingKeys: String, CodingKey {
            case id
            case dateTimeOrder
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(Int.self, forKey: .id)
            let createdDateStr = try values.decode(String.self, forKey: .dateTimeOrder)
            guard let _createdDate = createdDateStr.toISODate(nil, region: .UTC)?.date else {
                throw APIError.badMapping
            }
            dateTimeOrder = _createdDate
        }
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case operation
        case status
        case routeName
        case totalPrice
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        operation = try values.decode(ShortOrderOperation.self, forKey: .operation)
        status = try values.decode(RechkaOrderStatus.self, forKey: .status)
        totalPrice = try values.decode(Double.self, forKey: .totalPrice)
        routeName = try values.decodeIfPresent(String.self, forKey: .routeName)
        
    }
    
    
}

extension RechkaShortOrder {
    
    static func getOrders(size: Int = 10, page: Int = 0) async throws -> RechkaHistoryResponse {
        let client = APIClient.authorizedClient
        let query: [String: String] = ["size": "\(size)",
                      "page": "\(page)"]
        let ordersResponse: R_BaseResponse<RechkaHistoryResponse> = try await client.send(.GET(path: "/api/orders/v1/", query: query)).value
        return ordersResponse.data
    }
    
}
