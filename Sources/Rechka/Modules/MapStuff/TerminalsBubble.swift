//
//  TerminalBubbleView.swift
//  
//
//  Created by polykuzin on 16/03/2022.
//

import UIKit

internal final class TerminalBubbleView : UIView {
        
    public var onSelect : (() -> Void)?
    
    let bubbleView : UIView = {
        let view = UIView()
        view.alpha = 0.9
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.frame = CGRect(x: 0, y: 0, width: 230, height: 60)
        return view
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.label
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.customFont(forTextStyle: .body)
        label.frame = CGRect(x: 60, y: 0, width: 130, height: 60)
        return label
    }()
    
    let shipImageView : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 16, y: 17.5, width: 25, height: 25))
        imageView.tintColor = .label
        imageView.image = UIImage(named: "ship")!
        return imageView
    }()
    
    let chevronImageView : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 203, y: 22.5, width: 10, height: 15))
        imageView.tintColor = .label
        imageView.image = UIImage(systemName: "chevron.right")!
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        bubbleView.addSubview(titleLabel)
        bubbleView.addSubview(shipImageView)
        bubbleView.addSubview(chevronImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
