//
//  TicketsDetailsView.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit
import CoreTableView

protocol _TicietsDetailsView { }

final class TicketsDetailsView : UIView {
    
    var viewState: ViewState = .init(dataState: .loading, state: [], onClose: nil) {
        didSet {
            DispatchQueue.main.async {
                self.render()
            }
        }
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
    
    struct ViewState {
        
        enum DataState {
            case loading
            case loaded
            case error
        }
        
        let dataState: DataState
        let state: [State]
        let onClose: Command<Void>?
        
        struct Ticket : _TicketDetail {
            var price: String
            var place: String
            var number: String
            var passenger: String
            var onRefund: Command<Void>?
            var onDownload: Command<Void>?
            var downloadTitle: String
            var onRefundDetails: Command<Void>?
        }
        
        struct TicketStatus : _TicketStatus {
            var title: String
            
            var statusImage: UIImage
            
            var statusColor: UIColor
            
        }
        
        struct TicketInfo : _TicketInfo {
            var title : String
            var descr : String
            var image : UIImage
        }
        
        struct TicketTitle : _TicketTitle {
            var title : String
        }
    }
    
    @IBOutlet private weak var closeView : UIView!
    @IBOutlet private weak var tableView : BaseTableView!
    
    override func awakeFromNib() {
        closeView.layer.cornerRadius = UIScreen.main.displayCornerRadius
        closeView.layer.masksToBounds = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 115, right: 0)
    }
    
    
    @IBAction func handleClose(_ sender: UIButton) {
        self.viewState.onClose?.perform(with: ())
    }
    
}
