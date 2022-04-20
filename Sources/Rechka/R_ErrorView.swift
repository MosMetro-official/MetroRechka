//
//  R_ErrorView.swift
//  
//
//  Created by guseyn on 09.04.2022.
//

import UIKit

class R_ErrorView : UIView {
    
    internal let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ошибка"
        label.numberOfLines = 0
        label.font = Appearance.customFonts[.body]
        label.textAlignment = .center
        label.textColor = Appearance.colors[.textPrimary]
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

extension R_ErrorView {
    
    private func setup() {
        backgroundColor = Appearance.colors[.base]
        self.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            errorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32)
        ])
    }
    
    static func show(on view: UIView, with text: String, bgColor: UIColor, belowView: UIView? = nil) {
        let errorView = R_ErrorView(frame: view.frame)
        errorView.errorLabel.text = text
        errorView.backgroundColor = bgColor
        errorView.tag = 666
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
            if let belowView = belowView {
                view.insertSubview(errorView, belowSubview: belowView)
            }
            
        }
        animator.startAnimation()
    }
    
    static func removeErrorView(from view: UIView) {
        view.subviews.forEach { _view in
            if _view.tag == 666 {
                let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
                    _view.removeFromSuperview()
                }
                animator.startAnimation()
            }
        }
    }
}
