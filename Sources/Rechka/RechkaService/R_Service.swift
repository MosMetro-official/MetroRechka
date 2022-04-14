//
//  File.swift
//  
//
//  Created by guseyn on 09.04.2022.
//

import Foundation
import CoreNetwork


actor R_Service {
    
    func getTags(completion: @escaping (Result<[String],APIError>) -> Void)  {
        print("🔥🔥🔥 Started fetching tags")
        let client = APIClient.unauthorizedClient
        client.send(.GET(path: "/api/routes/v1/tags", query: nil)) { result in
            switch result {
                
            case .success(let response):
                let json = CoreNetwork.JSON(response.data)
                guard let array = json["data"].array else {
                    completion(.failure(.badMapping))
                    return
                }
                let tags = array.compactMap { $0.string }
                completion(.success(tags))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
        
    }
    
}
