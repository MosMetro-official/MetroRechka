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
    
    
    struct ViewState {
        let title: String
        let subtitle: String
        let image: UIImage
        let onClose: Command<Void>?
        let onRetry: Command<Void>?
        
        static let initial = ViewState(title: "", subtitle: "", image: UIImage(), onClose: nil, onRetry: nil)
    }
    
    var viewState: ViewState = .initial {
        didSet {
            DispatchQueue.main.async {
                self.render()
            }
        }
    }
    
    private func render() {
        self.title.text = viewState.title
        self.descr.text = viewState.subtitle
        self.resultImage.image = viewState.image
        self.retryButton.isHidden = viewState.onRetry == nil
    }
    
    
    @IBOutlet private weak var title : UILabel!
    
    @IBOutlet private weak var descr : UILabel!
    
    @IBOutlet private weak var retryButton : UIButton!
    
    @IBOutlet private weak var closeButton : UIButton!
    
    @IBOutlet private weak var resultImage : UIImageView!
    
    @IBAction private func onCloseSelect() {
        viewState.onClose?.perform(with: ())
    }
    
    @IBAction private func onRetrySelect() {
        viewState.onClose?.perform(with: ())
    }
    
    private func handleSuccess() {
        retryButton.isHidden = false
        resultImage.image = UIImage(named: "checkmark", in: .module, compatibleWith: nil)
    }
    
    private func handleFailure() {
        closeButton.backgroundColor = .clear
        resultImage.image = UIImage(named: "result_error", in: .module, compatibleWith: nil)
    }
    
   
}
