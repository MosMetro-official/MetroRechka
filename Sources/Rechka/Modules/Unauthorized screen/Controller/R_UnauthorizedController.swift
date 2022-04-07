//
//  R_UnauthorizedController.swift
//  
//
//  Created by guseyn on 01.04.2022.
//

import Foundation
import UIKit


internal final class R_UnauthorizedController: UIViewController {
    
    let nestedView = R_UnauthorizedView.loadFromNib()
    
    override func loadView() {
        super.loadView()
        self.view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}

