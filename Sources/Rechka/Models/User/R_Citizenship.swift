//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import CoreNetwork


struct R_Citizenship: Equatable {
    let id: Int
    let name: String
    let isonumeric: String
    let isoalpha2: String
    
    init?(data: CoreNetwork.JSON) {
        guard
            let id = data["id"].int,
            let name = data["name"].string,
            let isonumeric = data["isonumeric"].string,
            let isoalpha2 = data["isoalpha2"].string else { return nil }
        self.id = id
        self.name = name
        self.isonumeric = isonumeric
        self.isoalpha2 = isoalpha2
    }
}
