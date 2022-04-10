//
//  File.swift
//  
//
//  Created by guseyn on 10.04.2022.
//

import Foundation
import UIKit

class R_Toast: UIView {
    
    struct Configuration {
        let icon: UIImage?
        let title: String
        let subtitle: String?
        let titleColor: UIColor
        let subtitleColor: UIColor
        let actionType: ButtonType
        let backgroundColor: UIColor
        let tintColor: UIColor
        let cornerRadius: CGFloat
        
        
        enum ButtonType {
            case imageButton(Button)
            case textButton(Button)
        }
        
        struct Button {
            let image: UIImage?
            let title: String?
            let onSelect: () -> ()
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    private var onClose: (() ->())?
    private var onAction: (() -> ())?
    
    @IBAction private func handleAction(_ sender: UIButton) {
        onAction?()
    }
    
    @IBAction func handleClose(_ sender: Any) {
        self.onClose?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with configuration: Configuration) {
        [iconImageView, actionButton, closeButton].forEach {
            $0?.tintColor = configuration.tintColor
        }
        
        titleLabel.textColor = configuration.titleColor
        subtitleLabel.textColor = configuration.subtitleColor
        self.actionButton.setTitleColor(configuration.tintColor, for: .normal)
        
        self.iconImageView.image = configuration.icon
        self.iconImageView.isHidden = configuration.icon == nil
        
        self.roundCorners(.all, radius: configuration.cornerRadius)
        self.backgroundColor = configuration.backgroundColor
        self.titleLabel.text = configuration.title
        self.subtitleLabel.isHidden = configuration.subtitle == nil
        self.subtitleLabel.text = configuration.subtitle
        
        switch configuration.actionType {
        case .imageButton(let buttonData):
            self.onClose = buttonData.onSelect
            self.closeButton.setImage(buttonData.image, for: .normal)
            self.closeButton.isHidden = false
            self.actionButton.isHidden = true
        case .textButton(let buttonData):
            self.closeButton.isHidden = true
            self.actionButton.isHidden = false
            self.actionButton.setTitle(buttonData.title, for: .normal)
            self.onAction = buttonData.onSelect
        }
        
    }
    
    
}

extension R_Toast {
    
    static func show(on view: UIView, with configuration: R_Toast.Configuration, distanceFromBottom: CGFloat = 24) {
        let toast = R_Toast.loadFromNib()
        toast.configure(with: configuration)
        toast.tag = 555
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
            view.addSubview(toast)
            NSLayoutConstraint.activate([
                toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -distanceFromBottom),
                toast.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                toast.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
            ])
            
            
        }
        animator.startAnimation()
    }
    
    static func remove(from view: UIView) {
        view.subviews.forEach { _view in
            if _view.tag == 555 {
                let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
                    _view.removeFromSuperview()
                }
                animator.startAnimation()
            }
        }
    }
    
    
}


extension R_Toast.Configuration {
    
    static func defaultError(text: String, subtitle: String? = nil, buttonType: R_Toast.Configuration.ButtonType) -> R_Toast.Configuration {
        
        
        return R_Toast.Configuration(icon: nil,
                                     title: text,
                                     subtitle: subtitle,
                                     titleColor: .systemRed,
                                     subtitleColor: Appearance.colors[.textPrimary] ?? .label,
                                     actionType: buttonType,
                                     backgroundColor: Appearance.colors[.content] ?? .secondarySystemBackground,
                                     tintColor: Appearance.colors[.textPrimary] ?? .label,
                                     cornerRadius: 12)
    }
    
}
