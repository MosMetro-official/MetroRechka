//
//  R_TicketsDetailsView.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit
import CoreTableView


internal final class R_OrderDetailsView: UIView {
    
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
            var id: String
            var price: String
            var place: String
            var number: String
            var passenger: String
            var buttons: TicketDetailCell.Buttons
            var status: String
        }
        
        struct Error: _R_ErrorCell {
            var id: String = "error"
            var image: UIImage
            
            var title: String
            
            var action: Command<Void>?
            
            var buttonTitle: String?
            
            var height: CGFloat
            
        }
 
        struct TicketStatus : _TicketStatus {
            var id: String
            
            var title: String
            var statusImage: UIImage
            var statusColor: UIColor
        }
        
        struct TicketInfo : _TicketInfo {
            var id: String
            
            var height: CGFloat
            
            var title : String
            var descr : String
            var image : UIImage
        }
        
        struct TicketTitle : _TicketTitle {
            var id: String
            
            var title : String
        }
        
        struct Addtional: _Tariff {
            var id: String
            
            let tariffs: String
            let price: String
        }
        
        struct NeedToPay: _R_OrderPaymentTableViewCell {
            var id: String
            
            var onPay: Command<Void>
            var time: String
            var desc: String
        }
    }
    
    @IBOutlet private weak var closeView : UIView!
    @IBOutlet private weak var tableView : BaseTableView!
    
    override func awakeFromNib() {
        closeView.layer.cornerRadius = 10
        closeView.layer.cornerCurve = .continuous
        closeView.layer.masksToBounds = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 115, right: 0)
        tableView.shouldUseReload = true
    }
    
    @IBAction func handleClose(_ sender: UIButton) {
        self.viewState.onClose?.perform(with: ())
    }
}
