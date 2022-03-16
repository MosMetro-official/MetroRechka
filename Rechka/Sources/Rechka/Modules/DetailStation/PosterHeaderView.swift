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
        addSubview(containerView)
        containerView.addSubview(imageView)
        addSubview(titleLabel)
    }
    
    private func setViewConstrains() {
        NSLayoutConstraint.activate(
            [
                widthAnchor.constraint(equalTo: containerView.widthAnchor),
                centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                heightAnchor.constraint(equalTo: containerView.heightAnchor),
                
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 20),
                titleLabel.heightAnchor.constraint(equalToConstant: 100)
            ]
        )
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        containerViewHeight = containerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        containerViewHeight.isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageViewBottom = imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        imageViewBottom.isActive = true
        imageViewHeight = imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        imageViewHeight.isActive = true
        
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        containerViewHeight.constant = scrollView.contentInset.top
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        containerView.clipsToBounds = offsetY <= 0
        imageViewBottom.constant = offsetY >= 0 ? 0 : -offsetY / 2
        imageViewHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
    }
    
}
