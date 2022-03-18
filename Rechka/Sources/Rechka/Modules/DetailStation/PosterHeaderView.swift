//
//  PosterHeaderView.swift
//  
//
//  Created by Слава Платонов on 16.03.2022.
//

import UIKit

class PosterHeaderView: UIView {
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "poster", in: .module, with: nil)
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "MoscowSans-Regular", size: 24)
        return label
    }()
    
    private var imageViewHeight = NSLayoutConstraint()
    private var imageViewBottom = NSLayoutConstraint()
    private var containerView = UIView()
    private var containerViewHeight = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        setViewConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configurePosterHeader(with title: String) {
        titleLabel.text = title
        // image can be here to
    }
     
    private func createViews() {
        addSubview(imageView)
        imageView.addSubview(titleLabel)
    }
    
    private func setViewConstrains() {
        NSLayoutConstraint.activate(
            [
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                titleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 10),
                titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
                titleLabel.heightAnchor.constraint(equalToConstant: 100)
            ]
        )
        
    }
}
