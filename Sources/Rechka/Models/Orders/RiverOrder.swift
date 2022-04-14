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
    
    let operation: RiverOperation
    
    init?(data: CoreNetwork.JSON) {
        guard
            let id = data["id"].int,
            let url = data["formUrl"].string,
            let operation = RiverOperation(data: data["operation"], internalOrderID: id)
            else { return nil }
        self.id = id
        self.url = url
        self.operation = operation
        
    }
}



extension RiverOrder {
    
    func cancelBooking(completion: @escaping (Result<Void,APIError>) -> Void) {
        if case .booked = self.operation.status {
            let client = APIClient.authorizedClient
            client.send(.POST(path: "/api/orders/v1/\(self.id)/cancel", body: nil, contentType: .json)) { result in
                switch result {
                case .success(let response):
                    let json = CoreNetwork.JSON(response.data)
                    if let success = json["success"].bool, success {
                        print("successfully cancelled order")
                        completion(.success(()))
                        return
                    } else {
                        completion(.failure(APIError.genericError("Произошила ошибка при отмене бронирования")))
                        return
                    }
                case .failure(let error):
                    completion(.failure(error))
                    return
                }
            }
            
        } else {
            let err = APIError.genericError("Вы не можете произвести отмену этого бронирования")
            completion(.failure(err))
            return
           
        }
    }
    
    static func get(by id: Int, completion: @escaping (Result<RiverOrder,APIError>) -> Void){
        let client = APIClient.authorizedClient
        client.send(.GET(path: "/api/orders/v1/\(id)", query: nil)) { result in
            switch result {
            case .success(let response):
                let json = CoreNetwork.JSON(response.data)
                guard let order = RiverOrder(data: json["data"]) else {
                    completion(.failure(.badMapping))
                    return
                }
                completion(.success(order))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
}
