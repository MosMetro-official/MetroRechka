//
//  RechkaTerminals.swift
//  
//
//  Created by polykuzin on 15/03/2022.
//

import UIKit

protocol _RechkaTerminals {
    var title : String { get }
    var descr : String { get }
    var image : UIImage { get }
    var pinView : UIView? { get }
    var pinImage : UIImage? { get }
}

public struct RechkaTerminals : _RechkaTerminals {
    var title : String
    var descr : String
    var image : UIImage
    var pinView : UIView?
    var pinImage : UIImage?
}
