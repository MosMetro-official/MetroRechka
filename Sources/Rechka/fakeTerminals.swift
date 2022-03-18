//
//  File.swift
//  
//
//  Created by polykuzin on 15/03/2022.
//

import UIKit

public protocol _RechkaTerminal {
    var title : String { get }
    var descr : String { get }
    var latitude : Double { get }
    var longitude : Double { get }
    var onSelect : (() -> Void) { get }
}

struct FakeTerminal : _RechkaTerminal {
    let title : String
    let descr : String
    let latitude : Double
    let longitude : Double
    let onSelect : (() -> Void)
}
