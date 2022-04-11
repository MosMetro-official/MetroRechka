//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import CoreNetwork

struct R_Document: Equatable {
    let id: Int
    let name: String
    let inputMask: String
    let regularMask: String
    let useNumpadOnly: Bool
    let nationalityUse: Int
    let pictureIndex: Int
    let exampleNumber: String
    
    init?(data: CoreNetwork.JSON) {
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
}
