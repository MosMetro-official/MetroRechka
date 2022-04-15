//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import CoreNetwork

// MARK: - Gallery
public struct R_Gallery {
    let id: Int
    let title: String
    let galleryDescription: String?
    let urls: [String]
    
    init(data: CoreNetwork.JSON) {
        self.id = data["id"].intValue
        self.title = data["title"].stringValue
        self.galleryDescription = data["description"].string
        self.urls = data["urls"].arrayValue.compactMap {  $0.string }
    }
    
}
