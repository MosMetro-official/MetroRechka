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
    @IBOutlet weak var closeButton: UIButton!
    
    struct ViewState {
        let dataState: DataState
        let state: [State]
        let onClose: Command<Void>?
        
        enum DataState {
            case loading
            case loaded
            case error
        }
        
        struct Document: _Document {            
            let title: String
            let onItemSelect: Command<Void>
        }
        
        static let initial = R_DocumentView.ViewState(dataState: .loading, state: [], onClose: nil)
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
        closeButton.titleLabel?.font = .customFont(forTextStyle: .body)
    }
    
    @IBAction func tapOnClose() {
        viewState.onClose?.perform(with: ())
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
