//
//  R_DateCollectionCell.swift
//  
//
//  Created by guseyn on 13.04.2022.
//

import UIKit
import CoreTableView

protocol _R_DateCollectionCell {
    var time: String { get }
    var textColor: UIColor { get }
    var bgColor: UIColor { get }
    var borderColor: UIColor { get }
    var onSelect: Command<Void> { get }
    
}

class R_DateCollectionCell: UICollectionViewCell {
    
    private var borderColor : UIColor?
    
    @IBOutlet private weak var timeLabel: UILabel!
    
    @IBOutlet private weak var cardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.roundCorners(.all, radius: 18)
        self.cardView.layer.borderWidth = 0.5
    }
    
    override func layoutSubviews() {
        self.cardView.layer.borderColor = borderColor?.cgColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    func configure(with data: _R_DateCollectionCell) {
        borderColor = data.borderColor
        timeLabel.text = data.time
        timeLabel.textColor = data.textColor
        cardView.backgroundColor = data.bgColor
        cardView.layer.borderColor = data.borderColor.cgColor
    }
}
