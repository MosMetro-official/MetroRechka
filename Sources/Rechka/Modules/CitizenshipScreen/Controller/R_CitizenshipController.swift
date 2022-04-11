//
//  R_CitizenshipController.swift
//  
//
//  Created by Слава Платонов on 11.04.2022.
//

import UIKit
import CoreTableView

class R_CitizenshipController: UIViewController {
    
    let nestedView = R_CitizenshipView.loadFromNib()
    let network = R_Service()
    
    var onCitizenshipSelect: Command<R_Citizenship>?
    var citizenships: [R_Citizenship] = [] {
        didSet {
            Task.detached { [weak self] in
                await self?.makeState()
            }
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
        self.view.backgroundColor = Appearance.colors[.content]
        
    }
    
    private func loadCitizenships() {
        nestedView.viewState = .init(dataState: .loading, state: [])
        Task.detached { [weak self] in
            do {
                let citizenships = try await self?.network.getCitizenships()
                try await Task.sleep(nanoseconds: 0_300_000_000)
                await MainActor.run { [weak self] in
                    if let citizenships = citizenships {
                        self?.citizenships = citizenships
                    }
                }
            } catch {
                
            }
        }
    }
    
    private func makeState() async {
        let elements: [Element] = citizenships.map { citizen in
            let onSelect: () -> Void = { [weak self] in
                self?.onCitizenshipSelect?.perform(with: citizen)
                self?.dismiss(animated: true)
            }
            return R_CitizenshipView.ViewState.Citizenship(title: citizen.name, onSelect: onSelect).toElement()
        }
        let sec = SectionState(header: nil, footer: nil)
        let state = State(model: sec, elements: elements)
        await MainActor.run { [weak self] in
            let viewState = R_CitizenshipView.ViewState(dataState: .loaded, state: [state])
            self?.nestedView.viewState = viewState
        }
    }
    
}
