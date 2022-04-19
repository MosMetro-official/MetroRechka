//
//  R_Toast.swift
//  
//
//  Created by guseyn on 10.04.2022.
//

import UIKit

class R_Toast : UIView {
    
    struct Configuration {
        let icon : UIImage?
        let title : String
        let subtitle : String?
        let titleColor : UIColor
        let subtitleColor : UIColor
        let actionType : ButtonType
        let backgroundColor : UIColor
        let tintColor : UIColor
        let cornerRadius : CGFloat
        
        enum ButtonType {
            case textButton(Button)
            case imageButton(Button)
        }
        
        struct Button {
            let image : UIImage?
            let title : String?
            let onSelect : (() -> Void)
        }
    }
    
    @IBOutlet private weak var titleLabel : UILabel!
    
    @IBOutlet private weak var actionButton : UIButton!
    
    @IBOutlet private weak var subtitleLabel : UILabel!
    
    @IBOutlet private weak var iconImageView : UIImageView!
    
    @IBOutlet private weak var closeButton: UIButton!
    
    private var onClose: (() ->())?
    
    private var onAction: (() -> ())?
    
    @IBAction private func handleAction(_ sender: UIButton) {
        onAction?()
    }
    
    @IBAction private func handleClose(_ sender: Any) {
        onClose?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with configuration: Configuration) {
        [
            closeButton,
            actionButton,
            iconImageView,
        ].forEach {
            $0?.tintColor = configuration.tintColor
        }
        titleLabel.text = configuration.title
        backgroundColor = configuration.backgroundColor
        subtitleLabel.text = configuration.subtitle
        iconImageView.image = configuration.icon
        titleLabel.textColor = configuration.titleColor
        iconImageView.isHidden = configuration.icon == nil
        subtitleLabel.isHidden = configuration.subtitle == nil
        subtitleLabel.textColor = configuration.subtitleColor
        actionButton.setTitleColor(configuration.tintColor, for: .normal)
        
        roundCorners(.all, radius: configuration.cornerRadius)
        
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
        return R_Toast.Configuration(
            icon: nil,
            title: text,
            subtitle: subtitle,
            titleColor: .white,
            subtitleColor: .white.withAlphaComponent(0.75),
            actionType: buttonType,
            backgroundColor: .systemRed,
            tintColor: .white,
            cornerRadius: 12
        )
    }
}
