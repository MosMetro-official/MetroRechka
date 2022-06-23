//
//  R_CitizenshipController.swift
//  
//
//  Created by Слава Платонов on 11.04.2022.
//

import UIKit
import CoreTableView

class R_CitizenshipController : UIViewController {
    
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
        nestedView.backgroundColor = Appearance.colors[.base]
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
        nestedView.viewState = .init(onClose: nil, dataState: .loading, state: [], enableTextField: false)
        Task {
            do {
                self.citizenships = try await R_Citizenship.getCitizenships()
            } catch {
                print(error)
                let actionReload = Command { [weak self] in
                    self?.loadCitizenships()
                }
                let onClose = Command { [weak self] in
                    self?.dismiss(animated: true)
                }
                let error = R_CitizenshipView.ViewState.Error(
                    image: UIImage(named: "result_error", in: Rechka.shared.bundle, with: nil) ?? UIImage(),
                    title: "ЧТО-ТО ПОШЛО НЕ ТАК 😢",
                    action: actionReload,
                    buttonTitle: "Повторить",
                    height: UIScreen.main.bounds.height / 2
                ).toElement()
                let errorState = R_CitizenshipView.ViewState(
                    onClose: onClose,
                    dataState: .error,
                    state: [State(model: .init(header: nil, footer: nil), elements: [error])],
                    enableTextField: false
                )
                self.nestedView.viewState = errorState
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
            state: [state],
            enableTextField: true
        )
        self.nestedView.viewState = viewState
    }
}
