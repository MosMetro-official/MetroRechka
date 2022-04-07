//
//  File.swift
//  
//
//  Created by guseyn on 07.04.2022.
//

import Foundation

enum R_BlurResultModel {
    case success(StatusData)
    case failure(StatusData)
    
    struct StatusData {
        let title: String
        let subtitle: String
    }
}
