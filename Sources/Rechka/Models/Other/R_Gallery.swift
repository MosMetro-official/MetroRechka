//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import MMCoreNetworkAsync

// MARK: - Gallery
public struct R_Gallery: Decodable {
    public let id: Int
    public let title: String
    public let galleryDescription: String?
    public let urls: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case galleryDescription = "description"
        case urls
    }
    
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        galleryDescription = try values.decodeIfPresent(String.self, forKey: .galleryDescription)
        urls = try values.decode([String].self, forKey: .urls)
    }
    
    
}
