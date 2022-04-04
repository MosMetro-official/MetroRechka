//
//  File.swift
//  
//
//  Created by guseyn on 01.04.2022.
//

import Foundation
import UIKit


final class RUnauthorizedController: UIViewController {
    
    let nestedView = RUnauthorizedView.loadFromNib()
    
    override func loadView() {
        super.loadView()
        self.view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}

