//
//  R_Service.swift
//  
//
//  Created by guseyn on 09.04.2022.
//

import Foundation
import MMCoreNetworkAsync


final class R_Service {
    
    func getTags() async throws -> [String]  {
        
        
        print("🚢🚢🚢🚢 Started fetching tags")
        let client = APIClient.unauthorizedClient
        let response = try await client.send(  .GET(path: "/api/routes/v1/tags", query: nil))
        return try JSONDecoder().decode(R_BaseResponse<[String]>.self, from: response.data).data
       
    }
}
