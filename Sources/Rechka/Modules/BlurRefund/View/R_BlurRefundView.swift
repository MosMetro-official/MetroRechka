//
//  R_BlurRefundView.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit
import CoreTableView


protocol _BlurRefund {
    var title : String { get }
    var descr : String { get }
    var onCancel : (() -> Void) { get }
    var onSubmit : (() -> Void) { get }
}

internal final class R_BlurRefundView : UIView {
    
    @IBOutlet weak var loadingDescrLabel: UILabel!
    @IBOutlet weak var loadingTitle: UILabel!
    @IBOutlet weak var loadingView: UIView!
    
    @IBOutlet private weak var title : UILabel!
    @IBOutlet private weak var descr : UILabel!
        
    @IBOutlet private weak var cancelButton : UIButton!
    @IBOutlet private weak var submitButton : UIButton!
    
    enum ViewState {
        case loading(Loading)
        case loaded(LoadedState)
        case error
        
        struct Loading {
            let title: String
            let descr: String
        }
        
        struct LoadedState {
            let refunAmount: String
            let comission: String
            let onSubmit: Command<Void>
            let onClose: Command<Void>
        }
    }
    
    var viewState: ViewState = .loading(.init(title: "", descr: "")) {
        didSet {
            DispatchQueue.main.async {
                self.render()
            }
        }
    }
    
    private func render() {
        switch viewState {
        case .loading(let loading):
            [title,descr,cancelButton,submitButton].forEach { $0?.isHidden = true }
            loadingView.isHidden = false
            loadingTitle.text = loading.title
            loadingDescrLabel.text = loading.descr
        case .loaded(let loadedState):
            [title,descr,cancelButton,submitButton].forEach { $0?.isHidden = false }
            self.title.text = loadedState.refunAmount
            self.descr.text = loadedState.comission
            loadingView.isHidden = true
        case .error:
            [title,descr,cancelButton,submitButton].forEach { $0?.isHidden = true }
            loadingView.isHidden = false
        }
    }
    
    @IBAction private func onCancelSelect() {
        if case .loaded(let loadedData) = viewState {
            loadedData.onClose.perform(with: ())
        }
    }
    
    @IBAction private func onSubmitSelect() {
        if case .loaded(let loadedData) = viewState {
            loadedData.onSubmit.perform(with: ())
        }
    }
    
    override func awakeFromNib() {
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.custom(for: .emptyTicketsLayer).cgColor
    }
}
