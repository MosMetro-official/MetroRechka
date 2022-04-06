//
//  R_BlurResultView.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit

enum Result {
    case success
    case failure
}

protocol _BlurResult {
    var title : String { get }
    var descr : String { get }
    var result : Result { get }
    var onClose : (() -> Void) { get }
    var onRetry : (() -> Void) { get }
}

internal final class R_BlurResultView : UIView {
    
    public func configure(with data: _BlurResult) {
        title.text = data.title
        descr.text = data.descr
        handleResult(data.result)
    }
    
    private var onClose : (() -> Void)?
    
    private var onRetry : (() -> Void)?
    
    @IBOutlet private weak var title : UILabel!
    
    @IBOutlet private weak var descr : UILabel!
    
    @IBOutlet private weak var retryButton : UIButton!
    
    @IBOutlet private weak var closeButton : UIButton!
    
    @IBOutlet private weak var resultImage : UIImageView!
    
    @IBAction private func onCloseSelect() {
        onClose?()
    }
    
    @IBAction private func onRetrySelect() {
        onRetry?()
    }
    
    private func handleSuccess() {
        retryButton.isHidden = false
        resultImage.image = UIImage(named: "checkmark", in: .module, compatibleWith: nil)
    }
    
    private func handleFailure() {
        closeButton.backgroundColor = .clear
        resultImage.image = UIImage(named: "result_error", in: .module, compatibleWith: nil)
    }
    
    private func handleResult(_ status: Result) {
        switch status {
        case .success:
            handleSuccess()
        case .failure:
            handleFailure()
        }
    }
}
