//
//  RechkaMapDelegate.swift
//  
//
//  Created by polykuzin on 15/03/2022.
//

import UIKit


public protocol R_StationsController: UIViewController {
    
    var onStationSelect: ((R_Station) -> Void)? { get set }
    
    var stations: [R_Station] { get set }
    
}

public protocol R_RouteLineController: UIViewController {
    
    var route: R_Route? { get set }
    
}



public protocol RechkaMapDelegate : AnyObject {
    
    
    func rechkaRouteController(with route: R_Route) -> R_RouteLineController
    
    func rechkaStationsController() -> R_StationsController
}


