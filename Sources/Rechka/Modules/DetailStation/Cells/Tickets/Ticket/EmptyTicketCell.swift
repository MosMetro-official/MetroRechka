//
//  EmptyTicketCell.swift
//  
//
//  Created by Слава Платонов on 17.03.2022.
//

import UIKit

class EmptyTicketCell: UICollectionViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tarifLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 10
        contentView.layer.borderColor = UIColor.red.cgColor
        contentView.layer.borderWidth = 2
        priceLabel.font = UIFont(name: "MoscowSans-Regular", size: 16)
        tarifLabel.font = UIFont(name: "MoscowSans-Regular", size: 11)
    }

}
