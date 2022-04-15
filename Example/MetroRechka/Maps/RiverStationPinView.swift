//
//  ParkingPinView.swift
//  MosmetroNew
//
//  Created by Гусейн on 05.08.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit

class UIOutlinedLabel: UILabel {

    var outlineWidth: CGFloat = 2
    var outlineColor: UIColor = .systemBackground
    
    override func drawText(in rect: CGRect) {
        let shadowOffset = self.shadowOffset
        let textColor = self.textColor
        
        let c = UIGraphicsGetCurrentContext()
        c?.setLineWidth(outlineWidth)
        c?.setLineJoin(.round)
        c?.setTextDrawingMode(.stroke)
        self.textColor = outlineColor;
        super.drawText(in:rect)
        
        c?.setTextDrawingMode(.fill)
        self.textColor = textColor
        self.shadowOffset = CGSize(width: 0, height: 0)
        super.drawText(in:rect)
        
        self.shadowOffset = shadowOffset
    }
}


class RiverStationPinView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UIOutlinedLabel!
    
    
}
