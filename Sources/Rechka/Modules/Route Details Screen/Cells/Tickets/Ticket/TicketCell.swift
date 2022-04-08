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
    }
    
    func selectCell() {
        if isSelectable {
            selectedImage.image = isSelected ? UIImage(named: "select", in: .module, with: nil) : UIImage(named: "unselect", in: .module, with: nil)
            contentView.layer.borderColor = isSelected ? UIColor.custom(for: .priceLayer).cgColor : UIColor.custom(for: .textSecondary).cgColor
        }
    }
    
    public func configure(with data: FakeTickets) {
        if isSelectable {
            priceLabel.text = data.price
            tarifLabel.text = data.tariff
            selectedImage.image = UIImage(named: "unselect", in: .module, with: nil)
            contentView.layer.borderColor = UIColor.custom(for: .textSecondary).cgColor
        } else {
            priceLabel.text = data.price
            tarifLabel.text = data.tariff
            contentView.layer.borderColor = UIColor.custom(for: .priceLayer).cgColor
            selectedImage.isHidden = true
        }
    }

}
