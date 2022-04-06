//
//  R_BlurRefundView.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit

protocol _BlurRefund {
    var title : String { get }
    var descr : String { get }
    var onCancel : (() -> Void) { get }
    var onSubmit : (() -> Void) { get }
}

internal final class R_BlurRefundView : UIView {
    
    private var onCancel : (() -> Void)?
    
    private var onSubmit : (() -> Void)?
    
    public func configure(with data: _BlurRefund) {
        onCancel = data.onCancel
        onSubmit = data.onSubmit
        title.text = data.title
        descr.text = data.descr
    }
    
    @IBOutlet private weak var title : UILabel!
    
    @IBOutlet private weak var descr : UILabel!
        
    @IBOutlet private weak var cancelButton : UIButton!
    
    @IBOutlet private weak var submitButton : UIButton!
    
    @IBAction private func onCancelSelect() {
        onCancel?()
    }
    
    @IBAction private func onSubmitSelect() {
        onSubmit?()
    }
    
    override func awakeFromNib() {
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.custom(for: .emptyTicketsLayer).cgColor
    }
}
