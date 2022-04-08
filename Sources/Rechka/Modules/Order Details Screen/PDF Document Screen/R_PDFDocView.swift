//
//  PDFDocView.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 11.12.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit
import PDFKit
import CoreTableView

class R_PDFDocView: UIView {
    
    struct ViewState {
        var onSave: Command<Void>?
        var dataState: DataState
        var onClose: Command<Void>?
        
        enum DataState {
            case loading
            case loaded(PDFDocument)
            case error
        }
        
    }
    @IBOutlet weak var buttonsStackViewBottomAnchor: NSLayoutConstraint!
    
    var viewState: ViewState = .init(onSave: nil, dataState: .loading, onClose: nil) {
        didSet {
            render()
        }
    }
    
    
    @IBOutlet private weak var pdfView: PDFView!
    
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton!
    
    @IBAction func handleSave(_ sender: UIButton) {
        viewState.onSave?.perform(with: ())
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    @IBAction func handleClose(_ sender: UIButton) {
        viewState.onClose?.perform(with: ())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.buttonsStackViewBottomAnchor.constant = self.safeAreaInsets.bottom + 24
        let animator = UIViewPropertyAnimator(duration: 0.1, curve: .linear) { [weak self] in
            self?.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
}

extension R_PDFDocView {
    private func setup() {
        pdfView.autoScales = true
        [closeButton,saveButton].forEach {
            $0?.roundCorners(.all, radius: 8)
        }
    }
    
    private func render() {
        DispatchQueue.main.async {
            switch self.viewState.dataState {
            case .loading:
                self.showBlurLoading(on: self)
            case .loaded(let doc):
                self.removeBlurLoading(from: self)
                self.pdfView.document = doc
            case .error:
                self.removeBlurLoading(from: self)
                
            }
        }
    }
}
