//
//  R_CitizenshipController.swift
//  
//
//  Created by Слава Платонов on 11.04.2022.
//

import UIKit
import CoreTableView

class R_CitizenshipController: UIViewController {
    
    private let nestedView = R_CitizenshipView.loadFromNib()
    var onCitizenshipSelect: Command<R_Citizenship>?
    private var citizenships: [R_Citizenship] = [] {
        didSet {
            makeState()
        }
    }
    private var filter: [R_Citizenship] = [] {
        didSet {
            makeState()
        }
    }
    
    override func loadView() {
        super.loadView()
        self.view = nestedView
        nestedView.backgroundColor = Appearance.colors[.content]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCitizenships()
        nestedView.handleSearhText = { [weak self] text in
            guard let self = self else { return }
            self.filter = self.citizenships.filter { $0.name.lowercased().contains(text.lowercased()) }
        }
    }
    
    private func loadCitizenships() {
        nestedView.viewState = .init(onClose: nil, dataState: .loading, state: [])
        R_Citizenship.getCitizenships { result in
            switch result {
            case .success(let citizenships):
                self.citizenships = citizenships
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func makeState() {
        let currentList = filter.isEmpty ? citizenships : filter
        let elements: [Element] = currentList.map { citizen in
            let onSelect = Command { [weak self] in
                self?.onCitizenshipSelect?.perform(with: citizen)
                self?.dismiss(animated: true)
            }
            return R_CitizenshipView.ViewState.Citizenship(title: citizen.name, onItemSelect: onSelect).toElement()
        }
        let onClose = Command { [weak self] in
            self?.dismiss(animated: true)
        }
        let section = SectionState(header: nil, footer: nil)
        let state = State(model: section, elements: elements)
        let viewState = R_CitizenshipView.ViewState(
            onClose: onClose,
            dataState: .loaded,
            state: [state]
        )
        self.nestedView.viewState = viewState
    }
}
