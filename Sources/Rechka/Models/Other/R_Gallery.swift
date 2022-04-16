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
    public let id: Int
    public let title: String
    public let galleryDescription: String?
    public let urls: [String]
    
    init(data: CoreNetwork.JSON) {
        self.id = data["id"].intValue
        self.title = data["title"].stringValue
        self.galleryDescription = data["description"].string
        self.urls = data["urls"].arrayValue.compactMap {  $0.string }
    }
    
}
