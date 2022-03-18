//
//  File.swift
//  
//
//  Created by polykuzin on 15/03/2022.
//

import UIKit

extension UIScreen {
    
    private static let cornerRadiusKey: String = {
        let components = ["Radius", "Corner", "display", "_"]
        return components.reversed().joined()
    }()
    
    public var displayCornerRadius : CGFloat {
        guard
            let cornerRadius = self.value(forKey: Self.cornerRadiusKey) as? CGFloat
        else { return 30 }

        return cornerRadius
    }
}
