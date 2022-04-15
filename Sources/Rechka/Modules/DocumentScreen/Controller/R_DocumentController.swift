//
//  R_DocumentController.swift
//  
//
//  Created by Слава Платонов on 11.04.2022.
//

import UIKit
import CoreTableView

class R_DocumentController: UIViewController {

    let nestedView = R_DocumentView.loadFromNib()
    
    var onDocumentSelect: Command<R_Document>?
    var tripId: Int? {
        didSet {
            guard let id = tripId else { return }
            loadDocuments(by: id)
        }
    }
    var documents: [R_Document] = [] {
        didSet {
            makeState()
        }
    }
    
    override func loadView() {
        super.loadView()
        self.view = nestedView
        self.view.backgroundColor = .custom(for: .base)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func loadDocuments(by id: Int) {
        nestedView.viewState = .init(dataState: .loading, state: [], onClose: nil)
        R_Document.getDocs(by: id) { result in
            switch result {
            case .success(let doc):
                self.documents = doc
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func makeState() {
        let elements: [Element] = documents.map { document in
            let onSelect = Command { [weak self] in
                self?.onDocumentSelect?.perform(with: document)
                self?.dismiss(animated: true)
            }
            return R_DocumentView.ViewState.Document(title: document.name, onItemSelect: onSelect).toElement()
        }
        let onClose = Command { [weak self] in
            self?.dismiss(animated: true)
        }
        let sec = SectionState(header: nil, footer: nil)
        let state = State(model: sec, elements: elements)
        let viewState = R_DocumentView.ViewState(
            dataState: .loaded,
            state: [state],
            onClose: onClose
        )
        self.nestedView.viewState = viewState
    }

}
