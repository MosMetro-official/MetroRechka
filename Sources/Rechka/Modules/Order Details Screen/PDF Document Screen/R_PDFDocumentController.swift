//
//  PDFDocumentController.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 11.12.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import Foundation
import PDFKit
import CoreTableView

class PDFDocumentController: UIViewController {
    
    let pdfView = R_PDFDocView.loadFromNib()
    
//    var document: PDFDocument? {
//        didSet {
//            makeState()
//        }
//    }
    
    var filePath: URL? {
        didSet {
            self.makeState()
        }
    }
    
    var ticket: RiverOperationTicket? {
        didSet {
            guard let ticket = ticket else { return }
            Task {
                let filePath = try await ticket.getDocumentURL()
                self.filePath = filePath
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        self.view = pdfView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pdfView.viewState = .init(onSave: nil, dataState: .loading, onClose: nil)
    }
}

extension PDFDocumentController {
    
    
    private func set(state: R_PDFDocView.ViewState) {
        self.pdfView.viewState = state
    }
    
    
    private func set(filePath: URL) {
        self.filePath = filePath
    }
    
    private func makeState() {
        if let filePath = self.filePath {
            let onSave = Command { [weak self] in
                guard let self = self else { return }
                let activityViewController = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
            }
            
            let onClose = Command { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
            if let pdfDoc = PDFDocument(url: filePath) {
                let state = R_PDFDocView.ViewState(onSave: onSave, dataState: .loaded(pdfDoc), onClose: onClose)
                self.pdfView.viewState = state
                return
            }
        }
        
        let state = R_PDFDocView.ViewState(onSave: nil, dataState: .error, onClose: nil)
        self.pdfView.viewState = state
        return
    }
}
