//
//  R_DocumentView.swift
//  
//
//  Created by Слава Платонов on 11.04.2022.
//

import UIKit
import CoreTableView

class R_DocumentView: UIView {

    @IBOutlet weak var tableView: BaseTableView!
    
    struct ViewState {
        let dataState: DataState
        let state: [State]
        
        enum DataState {
            case loading
            case loaded
            case error
        }
        
        struct Document: _Document {            
            let title: String
            let onSelect: () -> Void
        }
        
        static let initial = R_DocumentView.ViewState(dataState: .loading, state: [])
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
        backgroundColor = .custom(for: .base)
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 20, right: 0)
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
