//
//  R_CitizenshipView.swift
//  
//
//  Created by Слава Платонов on 11.04.2022.
//

import UIKit
import CoreTableView

class R_CitizenshipView: UIView {
    
    @IBOutlet weak var tableView: BaseTableView!
    
    struct ViewState {
        let dataState: DataState
        let state: [State]
        
        enum DataState {
            case loading
            case loaded
            case error
        }
        
        struct Citizenship: _Citizenship {
            let title: String
            let onSelect: () -> Void
        }
        
        static let initial = R_CitizenshipView.ViewState(dataState: .loading, state: [])
    }
    
    var viewState: ViewState = .initial {
        didSet {
            DispatchQueue.main.async {
                self.render()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func render() {
        switch viewState.dataState {
        case .loading:
            self.showBlurLoading(on: self)
        case .loaded:
            self.removeBlurLoading(from: self)
        case .error:
            self.removeBlurLoading(from: self)
        }
        self.tableView.viewStateInput = viewState.state
    }
    
}
