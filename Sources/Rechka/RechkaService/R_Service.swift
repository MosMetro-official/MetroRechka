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
    
    func getDocs(by id: Int) async throws -> [R_Document] {
        let client = APIClient.unauthorizedClient
        do {
            let response = try await client.send(
                .GET(
                    path: "/api/references/v1/idCards/\(id)",
                    query: nil)
            )
            let json = CoreNetwork.JSON(response.data)
            guard let array = json["data"].array else {
                throw APIError.badData
            }
            
            let avalibleDocs = array.compactMap { R_Document(data: $0) }
            return avalibleDocs
        } catch {
            guard let err = error as? APIError else { throw error }
            print(err)
            throw err
        }
    }
    
    func getCitizenships() async throws -> [R_Citizenship] {
        let client = APIClient.unauthorizedClient
        do {
            let response = try await client.send(
                .GET(
                    path: "/api/references/v1/citizenship",
                    query: nil)
            )
            let json = CoreNetwork.JSON(response.data)
            guard let array = json["data"].array else {
                throw APIError.badData
            }
            
            let citizenships = array.compactMap { R_Citizenship(data: $0) }
            return citizenships
        } catch {
            guard let err = error as? APIError else { throw error }
            print(err)
            throw err
        }
    }
}
