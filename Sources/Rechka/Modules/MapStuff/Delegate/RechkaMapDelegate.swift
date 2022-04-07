//
//  File.swift
//  
//
//  Created by polykuzin on 15/03/2022.
//

import UIKit

public protocol RechkaMapController : UIViewController {
    
    var delegate : RechkaMapReverceDelegate? { get set }
    
    var terminals : [_RiverStation] { get set }
    
    var terminalsImages : [UIImage] { get set }
    
    var shouldShowTerminalsButton : Bool { get set }
    
    func showTerminalListButton()
    
    func showTerminalsOnMap(from images: [UIImage], and for: [_RiverStation])
}

public protocol RechkaMapDelegate : AnyObject {
        
    func getRechkaMapController() -> RechkaMapController
}

public protocol RechkaMapReverceDelegate : AnyObject {
        
    func onMapBackSelect()
    
    func onTerminalsListSelect()
}
