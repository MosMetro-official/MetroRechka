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
    let network = R_Service()
    
    var onDocumentSelect: Command<R_Document>?
    var tripId: Int? {
        didSet {
            guard let id = tripId else { return }
            loadDocuments(by: id)
        }
    }
    var documents: [R_Document] = [] {
        didSet {
            Task.detached { [weak self] in
                await self?.makeState()
            }
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
        nestedView.viewState = .init(dataState: .loading, state: [])
        Task.detached { [weak self] in
            do {
                let availableDocuments = try await self?.network.getDocs(by: id)
                try await Task.sleep(nanoseconds: 0_300_000_000)
                await MainActor.run { [weak self] in
                    if let documents = availableDocuments {
                        self?.documents = documents
                    }
                }
            } catch {
                
            }
        }
    }
    
    private func makeState() async {
        let elements: [Element] = documents.map { document in
            let onSelect: () -> Void = { [weak self] in
                self?.onDocumentSelect?.perform(with: document)
                self?.dismiss(animated: true)
            }
            return R_DocumentView.ViewState.Document(title: document.name, onSelect: onSelect).toElement()
        }
        let sec = SectionState(header: nil, footer: nil)
        let state = State(model: sec, elements: elements)
        await MainActor.run { [weak self] in
            let viewState = R_DocumentView.ViewState(dataState: .loaded, state: [state])
            self?.nestedView.viewState = viewState
        }
    }

}
