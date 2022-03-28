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
    internal func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    /**
     Load the view from a nib file called with the name of the class;
      - note: The first object of the nib file **must** be of the matching class
      - parameters:
        - none
     */
    static internal func loadFromNib() -> Self {
        let bundle = Bundle.module
        let nib = UINib(nibName: String(describing: self), bundle: bundle)
        return nib.instantiate(withOwner: nil, options: nil).first as! Self
    }
}
