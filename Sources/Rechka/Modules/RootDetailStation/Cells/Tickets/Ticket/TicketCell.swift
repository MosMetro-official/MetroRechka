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
    
    var isSelectable: Bool = false
    private var gradient: CAGradientLayer?
    
    override var isSelected: Bool {
        didSet {
            selectCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 2
        priceLabel.font = UIFont(name: "MoscowSans-Regular", size: 16)
        tarifLabel.font = UIFont(name: "MoscowSans-Regular", size: 11)
        addGradient()
    }
    
    private func addGradient() {
        self.gradient = CAGradientLayer()
        guard let gradient = gradient else {
            return
        }
        gradient.frame =  CGRect(origin: CGPoint(x: 20, y: 8), size: .init(width: UIScreen.main.bounds.width - 40, height: 104))
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
    
    func selectCell() {
        if isSelectable {
            selectedImage.image = isSelected ? UIImage(named: "select", in: .module, with: nil) : UIImage(named: "unselect", in: .module, with: nil)
            contentView.layer.borderColor = isSelected ? UIColor.custom(for: .priceLayer).cgColor : UIColor.custom(for: .textSecondary).cgColor
        }
    }
    
    public func configure(with data: RiverTariff) {
        if isSelectable {
            priceLabel.text = String(data.price)
            tarifLabel.text = data.name
            selectedImage.image = UIImage(named: "unselect", in: .module, with: nil)
            contentView.layer.borderColor = UIColor.custom(for: .textSecondary).cgColor
        } else {
            priceLabel.text = String(data.price)
            tarifLabel.text = data.name
            contentView.layer.borderColor = UIColor.custom(for: .priceLayer).cgColor
            selectedImage.isHidden = true
        }
    }

}
