//
//  R_PosterTableHeaderView.swift
//  
//
//  Created by Слава Платонов on 16.03.2022.
//

import UIKit
import SDWebImage

internal final class R_PosterTableHeaderView : UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        gradientView.frame = frame
        createViews()
        setViewConstrains()
    }
    
    private let gradientView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let image = UIImageView()
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
    
    private var gradient : CAGradientLayer?
    
    private var imageViewHeight = NSLayoutConstraint()
    
    private var imageViewBottom = NSLayoutConstraint()
    
    private var containerViewHeight = NSLayoutConstraint()
    
    private var imageURL: String? {
        didSet {
            if let imageURL = imageURL {
                guard let photoURL = URL(string: imageURL) else { return }
                imageView.sd_setImage(with: photoURL, completed: nil)
            }
        }
    }
    
    private func addGradient() {
        self.gradient = CAGradientLayer()
        guard let gradient = gradient else {
            return
        }
        gradient.frame =  CGRect(origin: CGPoint(x: 0, y: self.gradientView.bounds.height / 2), size: .init(width: UIScreen.main.bounds.width, height: self.gradientView.frame.height / 2))
        let base = Appearance.colors[.base] ?? UIColor.clear
        
        gradient.colors = [base.withAlphaComponent(0).cgColor, base.cgColor]
        self.gradientView.layer.insertSublayer(gradient, at: 0)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let base = Appearance.colors[.base] ?? UIColor.clear
        guard let gradient = gradient else { return }
        gradient.colors = [base.withAlphaComponent(0).cgColor, base.cgColor]
        gradient.frame = .init(x: 0, y: self.gradientView.frame.height/2, width: self.gradientView.frame.width, height: self.gradientView.frame.height/2)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    public func configurePosterHeader(with title: String?, and imageURL: String?) {
        titleLabel.text = title
        imageView.image = UIImage(named: "poster", in: Rechka.shared.bundle, with: nil)
        self.imageURL = imageURL
    }
    
    private func createViews() {
        addSubview(containerView)
        containerView.addSubview(imageView)
        addSubview(titleLabel)
        containerView.addSubview(gradientView)
        addGradient()
    }
    
    private func setViewConstrains() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: containerView.widthAnchor),
            centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            heightAnchor.constraint(equalTo: containerView.heightAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 30),
            titleLabel.heightAnchor.constraint(equalToConstant: 100),
            
            gradientView.topAnchor.constraint(equalTo: containerView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        containerView.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        containerViewHeight = containerView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: 20)
        containerViewHeight.isActive = true
        
        imageViewBottom = imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        imageViewBottom.isActive = true
        imageViewHeight = imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, constant: 20)
        imageViewHeight.isActive = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        containerViewHeight.constant = scrollView.contentInset.top
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        containerView.clipsToBounds = offsetY <= 0
        imageViewBottom.constant = offsetY >= 0 ? 0 : -offsetY / 2
        imageViewHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
    }
}
