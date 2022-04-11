//
//  SafeIndex.swift
//  
//
//  Created by Слава Платонов on 28.03.2022.
//

import Foundation

public extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
