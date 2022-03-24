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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 10
        contentView.layer.borderColor = UIColor.custom(for: .priceLayer).cgColor
        contentView.layer.borderWidth = 2
        priceLabel.font = UIFont(name: "MoscowSans-Regular", size: 16)
        tarifLabel.font = UIFont(name: "MoscowSans-Regular", size: 11)
        // Initialization code
    }
    
    public func configure(with data: FakeTickets) {
        priceLabel.text = data.price
        tarifLabel.text = data.tariff
    }

}
