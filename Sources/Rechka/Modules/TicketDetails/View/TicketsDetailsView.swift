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
    
    public func configure(with data: [State]) {
        DispatchQueue.main.async {
            self.tableView.viewStateInput = data
        }
    }
    
    struct ViewState {
        
        struct Ticket : _TicketDetail {
            var price: String
            var place: String
            var number: String
            var passenger: String
            var onRefund: (() -> Void)
            var onDownload: (() -> Void)
            var downloadTitle: String
            var onRefundDetails: (() -> Void)
        }
        
        struct TicketStatus : _TicketStatus {
            var title : String
            var status : PurchaseStatus
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
}
