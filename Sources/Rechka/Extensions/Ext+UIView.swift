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
    
    // MARK: - Load From Nib
    /**
     Load the view from a nib file called with the name of the class;
      - note: The first object of the nib file **must** be of the matching class
      - parameters:
        - none
     */
    static func loadFromNib() -> Self {
        let nib = UINib(nibName: String(describing: self), bundle: .module)
        //  swiftlint:disable force_cast
        return nib.instantiate(withOwner: nil, options: nil).first as! Self
        //  swiftlint:enable force_cast
    }
}
