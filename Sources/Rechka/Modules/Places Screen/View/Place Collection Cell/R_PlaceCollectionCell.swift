//
//  BusPlaceCollectionCell.swift
//  MosmetroNew
//
//  Created by Гусейн on 03.12.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit
import CoreTableView

protocol _R_PlaceCollectionCell {
    
    var text: String { get }
    var isSelected: Bool { get }
    var onSelect: Command<Void> { get }
    var isUnvailable: Bool { get }
    
}


class R_PlaceCollectionCell: UICollectionViewCell {

    @IBOutlet private var backView: UIView!
    @IBOutlet private var numberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.roundCorners(.all, radius: 16)
    }
    
    func configure(data: _R_PlaceCollectionCell) {
        self.numberLabel.text = data.text
        self.backView.backgroundColor = data.isSelected ? Appearance.colors[.buttonSecondary] : Appearance.colors[.content]
        self.numberLabel.textColor = data.isSelected ? Appearance.colors[.textInverted] : Appearance.colors[.textPrimary]
        self.backView.layer.borderColor = data.isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        self.backView.layer.borderWidth = data.isSelected ? 1 : 0
        self.backView.alpha = data.isUnvailable ? 0.4 : 1
    }

}
