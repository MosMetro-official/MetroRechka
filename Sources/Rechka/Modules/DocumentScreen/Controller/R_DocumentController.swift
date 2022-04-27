//
//  R_DocumentController.swift
//  
//
//  Created by Слава Платонов on 11.04.2022.
//

import UIKit
import CoreTableView

class R_DocumentController: UIViewController {

    private let nestedView = R_DocumentView.loadFromNib()
    var onDocumentSelect: Command<R_Document>?
    var tripId: Int? {
        didSet {
            guard let id = tripId else { return }
            loadDocuments(by: id)
        }
    }
    private var documents: [R_Document] = [] {
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
                let actionReload = Command { [weak self] in
                    self?.loadDocuments(by: id)
                }
                let onClose = Command { [weak self] in
                    self?.dismiss(animated: true)
                }
                let error = R_DocumentView.ViewState.Error(
                    image: UIImage(named: "result_error", in: Rechka.shared.bundle, with: nil) ?? UIImage(),
                    title: "ЧТО-ТО ПОШЛО НЕ ТАК 😢",
                    action: actionReload,
                    buttonTitle: "Повторить",
                    height: UIScreen.main.bounds.height / 2
                ).toElement()
                let errorState = R_DocumentView.ViewState(
                    dataState: .error,
                    state: [State(model: .init(header: nil, footer: nil), elements: [error])],
                    onClose: onClose
                )
                self.nestedView.viewState = errorState
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
