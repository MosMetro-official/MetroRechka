//
//  File.swift
//  
//
//  Created by Слава Платонов on 18.03.2022.
//

import UIKit

final class GradientView: UIImageView {
    override func layoutSubviews() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.custom(for: .base).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.6)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
}
