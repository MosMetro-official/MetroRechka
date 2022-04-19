//
//  R_UnauthorizedView.swift
//  
//
//  Created by guseyn on 01.04.2022.
//

import UIKit
import SafariServices
import CoreTableView

internal final class R_UnauthorizedView: UIView {
    
    @IBOutlet weak var loginButton : UIButton!
    
    @IBOutlet weak var closeButton : UIButton!
    
    @IBOutlet weak var effectView : UIVisualEffectView!
    
    @IBOutlet weak var scrollView : UIScrollView!
    
    struct ViewState {
        let onMore: Command<Void>?
        let onClose: Command<Void>?
        let onLogin: Command<Void>?
    }
    
    var viewState: ViewState = .init(onMore: nil, onClose: nil, onLogin: nil)
    
    @IBAction func handleMore(_ sender: UIButton) {
        viewState.onMore?.perform(with: ())
        
    }
    
    @IBAction func handleClose(_ sender: UIButton) {
        viewState.onClose?.perform(with: ())
    }
    
    @IBAction func handleLogin(_ sender: UIButton) {
        viewState.onLogin?.perform(with: ())
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.loginButton.roundCorners(.all, radius: 8)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.effectView.frame.height, right: 0)
    }
}

extension R_UnauthorizedView {
    
    private func setup() { }
}
