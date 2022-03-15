//
//  File.swift
//  
//
//  Created by polykuzin on 15/03/2022.
//

import UIKit

extension UIView {
    
    /**
    Converts the view into an image
     */
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
