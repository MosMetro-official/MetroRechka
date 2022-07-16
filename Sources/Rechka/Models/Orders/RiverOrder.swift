//
//  File.swift
//  
//
//  Created by guseyn on 04.04.2022.
//

import Foundation
import MMCoreNetworkAsync

struct RiverOrder: Decodable {
    let id: Int
    /// payment url
    let url: String
    
    let operation: RiverOperation
    
    
    private enum CodingKeys: String, CodingKey {
        case id
        case url = "formUrl"
        case operation = "operation"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.url = try values.decode(String.self, forKey: .url)
        let operationContainer = try values.nestedContainer(keyedBy: RiverOperation.CodingKeys.self, forKey: .operation)
        
        //var operation = try values.decode(RiverOperation.self, forKey: .operation)
        //operation.internalOrderID = id
        self.operation = try RiverOperation(internalOrderID: id, container: operationContainer)
        
    }
}



extension RiverOrder {
    
    func cancelBooking() async throws {
        if case .booked = self.operation.status {
            let client = APIClient.authorizedClient
            try await client.send(.POST(path: "/api/orders/v1/\(self.id)/cancel", contentType: .json))
    
            
//            client.send(.POST(path: "/api/orders/v1/\(self.id)/cancel", body: nil, contentType: .json)) { result in
//                switch result {
//                case .success(let response):
//                    let json = JSON(response.data)
//                    if let success = json["success"].bool, success {
//                        print("successfully cancelled order")
//                        completion(.success(()))
//                        return
//                    } else {
//                        completion(.failure(APIError.genericError("Произошила ошибка при отмене бронирования")))
//                        return
//                    }
//                case .failure(let error):
//                    completion(.failure(error))
//                    return
//                }
//            }
            
        } else {
            let err = APIError.genericError("Вы не можете произвести отмену этого бронирования")
            throw err
        }
    }
    
    static func get(by id: Int) async throws -> RiverOrder {
        let client = APIClient.authorizedClient
        let order: R_BaseResponse<RiverOrder> = try await client.send(.GET(path: "/api/orders/v1/\(id)")).value
        return order.data
    }
}
