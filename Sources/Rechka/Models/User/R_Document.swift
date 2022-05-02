//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import MMCoreNetworkCallbacks

struct R_Document: Equatable {
    let id: Int
    let name: String
    let inputMask: String
    let regularMask: String
    let useNumpadOnly: Bool
    let nationalityUse: Int
    let pictureIndex: Int
    let exampleNumber: String
    var cardIdentityNumber: String?
    
    init?(data: JSON) {
        guard
            let id = data["id"].int,
            let name = data["name"].string,
            let inputMask = data["inputMask"].string,
            let regularMask = data["regularMask"].string,
            let useNumpadOnly = data["useNumpadOnly"].bool,
            let nationalityUse = data["nationalityUse"].int,
            let pictureIndex = data["pictureIndex"].int,
            let exampleNumber = data["exampleNumber"].string else { return nil }
        self.id = id
        self.name = name
        self.inputMask = inputMask
        self.regularMask = regularMask
        self.useNumpadOnly = useNumpadOnly
        self.nationalityUse = nationalityUse
        self.pictureIndex = pictureIndex
        self.exampleNumber = exampleNumber
    }
    
    static func getDocs(by id: Int, completion: @escaping (Result<[R_Document], APIError>) -> Void) {
        let client = APIClient.unauthorizedClient
        client.send(.GET(path: "/api/references/v1/idCards/\(id)")) { result in
            switch result {
            case .success(let repsonse):
                let json = JSON(repsonse.data)
                guard let array = json["data"].array else {
                    completion(.failure(.badMapping))
                    return
                }
                let docs = array.compactMap { R_Document(data: $0) }
                completion(.success(docs))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
}
