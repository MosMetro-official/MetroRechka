//
//  CancelBookingView.swift
//  
//
//  Created by polykuzin on 24/03/2022.
//

import UIKit

final class CancelBookingView : UIView {
    
    public var onCloseTap : (() -> Void)?
    
    @IBOutlet private weak var closeButton : UIButton!
    
    override func awakeFromNib() {
        self.closeButton.addTarget(self, action: #selector(onCloseSelected), for: .touchUpInside)
    }
    
    @objc
    private func onCloseSelected() {
        self.onCloseTap?()
    }
}
