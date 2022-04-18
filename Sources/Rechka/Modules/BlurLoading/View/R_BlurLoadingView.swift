//
//  R_BlurLoadingView.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit

protocol _BlurLoading {
    var title : String { get }
    var descr : String { get }
}

internal final class R_BlurLoadingView : UIView {
    
    public func configure(with data: _BlurLoading) {
        title.text = data.title
        descr.text = data.descr
    }
    
    @IBOutlet private weak var title : UILabel!
    
    @IBOutlet private weak var descr : UILabel!
    
    @IBOutlet private weak var spinner : UIActivityIndicatorView!
}


extension UIView {
    
    func showBlurLoading(on view: UIView) {
        let blurView = R_BlurLoadingView.loadFromNib()
        blurView.tag = 777
        blurView.frame = view.frame
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
            view.addSubview(blurView)
        }
        animator.startAnimation()
    }
    
    func removeBlurLoading(from view: UIView) {
        view.subviews.forEach { _view in
            if _view.tag == 777 {
                let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
                    _view.removeFromSuperview()
                }
                animator.startAnimation()
            }
        }
    }
    
    
    func showBlurLoading() {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        let blurView = R_BlurLoadingView.loadFromNib()
        blurView.tag = 777
        blurView.frame = window.frame
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
            window.addSubview(blurView)
        }
        animator.startAnimation()
        
    }
    
    func removeBlurLoading() {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        window.subviews.forEach { view in
            if view.tag == 777 {
                let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
                    view.removeFromSuperview()
                }
                animator.startAnimation()
            }
        }
    }
    
}
