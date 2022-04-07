//
//  PDFDocumentController.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 11.12.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import Foundation
import PDFKit

class PDFDocumentController: UIViewController {
    
    let pdfView = R_PDFDocView.loadFromNib()
    
//    var document: PDFDocument? {
//        didSet {
//            makeState()
//        }
//    }
    
    var filePath: URL? {
        didSet {
            Task.detached { [weak self] in
                guard let self = self else { return }
                let state = await self.makeState()
                await self.set(state: state)
            }
        }
    }
    
    var ticket: RiverOperationTicket? {
        didSet {
            guard let ticket = ticket else { return }
            Task.detached { [weak self] in
                guard let self = self else { return }
                do {
                    let filePath = try await ticket.getDocumentURL()
                    await self.set(filePath: filePath)
                } catch {
                    print("Error: \(error)")
                    // handle error
                }
              
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
    
    @MainActor
    private func set(state: R_PDFDocView.ViewState) {
        self.pdfView.viewState = state
    }
    
    @MainActor
    private func set(filePath: URL) {
        self.filePath = filePath
    }
    
    private func makeState() async -> R_PDFDocView.ViewState {
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
                return .init(onSave: onSave, dataState: .loaded(pdfDoc), onClose: onClose)
            }
        }
        return .init(onSave: nil, dataState: .error, onClose: nil)
    }
}
