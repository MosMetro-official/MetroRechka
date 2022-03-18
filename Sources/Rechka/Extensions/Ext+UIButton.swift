//
//  Ext+UIButton.swift
//  
//
//  Created by Слава Платонов on 09.03.2022.
//

import UIKit

extension UIButton {
    func addHorizontalGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [#colorLiteral(red: 0, green: 0.4075400233, blue: 0.7539479136, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0.7945067286, blue: 0.8337443471, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
