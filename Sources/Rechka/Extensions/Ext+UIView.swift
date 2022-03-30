//
//  File.swift
//  
//
//  Created by polykuzin on 15/03/2022.
//

import UIKit

typealias EdgeClosure = (_ view: UIView, _ superview: UIView) -> ([NSLayoutConstraint])

enum Corners {
    case all
    case top
    case bottom
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case allButTopLeft
    case allButTopRight
    case allButBottomLeft
    case allButBottomRight
    case left
    case right
    case topLeftBottomRight
    case topRightBottomLeft
}

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
    
    /**
     Sets the cornerRadius for selected corners from **Corners** enum
     - parameters:
        - corners:
            * all
            * top
            * bottom
            * topLeft
            * topRight
            * bottomLeft
            * bottomRight
            * allButTopLeft
            * allButTopRight
            * allButBottomLeft
            * allButBottomRight
            * left
            * right
            * topLeftBottomRight
            * topRightBottomLeft
        - radius: The **CGFloat** value to be set
     */
    func roundCorners(_ corners: Corners, radius: CGFloat) {
        var cornerMasks = [CACornerMask]()
        
        // Top left corner
        switch corners {
        case .all, .top, .topLeft, .allButTopRight, .allButBottomLeft, .allButBottomRight, .topLeftBottomRight, .left:
            cornerMasks.append(CACornerMask(rawValue: UIRectCorner.topLeft.rawValue))
        default:
            break
        }
        
        // Top right corner
        switch corners {
        case .all, .top, .topRight, .allButTopLeft, .allButBottomLeft, .allButBottomRight, .topRightBottomLeft:
            cornerMasks.append(CACornerMask(rawValue: UIRectCorner.topRight.rawValue))
        default:
            break
        }
        
        // Bottom left corner
        switch corners {
        case .all, .bottom, .bottomLeft, .allButTopRight, .allButTopLeft, .allButBottomRight, .topRightBottomLeft, .left:
            cornerMasks.append(CACornerMask(rawValue: UIRectCorner.bottomLeft.rawValue))
        default:
            break
        }
        
        // Bottom right corner
        switch corners {
        case .all, .bottom, .bottomRight, .allButTopRight, .allButTopLeft, .allButBottomLeft, .topLeftBottomRight:
            cornerMasks.append(CACornerMask(rawValue: UIRectCorner.bottomRight.rawValue))
        default:
            break
        }
        
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
        layer.maskedCorners = CACornerMask(cornerMasks)
    }
}
