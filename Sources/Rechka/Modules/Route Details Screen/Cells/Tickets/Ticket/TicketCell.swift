//
//  TicketCell.swift
//  
//
//  Created by Слава Платонов on 17.03.2022.
//

import UIKit

class TicketCell: UICollectionViewCell {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tarifLabel: UILabel!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var cardView: UIView!
    
    private var gradient: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = Appearance.colors[.textSecondary]?.cgColor
        priceLabel.font = UIFont(name: "MoscowSans-Regular", size: 16)
        tarifLabel.font = UIFont(name: "MoscowSans-Regular", size: 11)
        addGradient()
    }
    
    private func addGradient() {
        self.gradient = CAGradientLayer()
        guard let gradient = gradient else {
            return
        }
        gradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: .init(width: UIScreen.main.bounds.width * 0.4, height: frame.height - 40))
        gradient.colors = [UIColor.from(hex: "#4AC7FA").cgColor, UIColor.from(hex: "#E649F5").cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        let shape = CAShapeLayer()
        shape.lineWidth = 1.5
        shape.path =  UIBezierPath(roundedRect: CGRect(origin: .zero, size: gradient.frame.size).insetBy(dx: 1.5, dy: 1.5), cornerRadius: 12).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        self.layer.addSublayer(gradient)
    }
    
    public func configure(with data: R_Tariff, and select: Bool) {
        self.priceLabel.text = "\(Int(data.price)) P"
        self.tarifLabel.text = data.name
        selectedImage.image = select ? UIImage(named: "select", in: .module, with: nil) : UIImage(named: "unselect", in: .module, with: nil)
        gradient?.isHidden = select ? false : true
    }
}
