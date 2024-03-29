//
//  TicketsHeader.swift
//  
//
//  Created by Слава Платонов on 17.03.2022.
//

import UIKit
import CoreTableView

protocol _TicketsHeader: HeaderData {
    var ticketsCount: Int { get }
    var title: String { get }
    var isInsetGroup: Bool { get }
}

extension _TicketsHeader {
    
    var height: CGFloat {
        return 50
    }
    
    func hashValues() -> [Int] {
        return [
            ticketsCount.hashValue,
            title.hashValue,
            isInsetGroup.hashValue
        ]
    }
        
    var isInsetGroup: Bool { return false }
    
    func header(for tableView: UITableView, section: Int) -> UIView? {
        tableView.register(TicketsHeader.nib, forHeaderFooterViewReuseIdentifier: TicketsHeader.identifire)
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TicketsHeader.identifire) as? TicketsHeader else { return nil }
        header.configure(with: self)
        return header
    }
}

class TicketsHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var ticketLabel : UILabel!
    
    @IBOutlet weak var lowTicketsCount : UILabel!
    
    @IBOutlet weak var leftConstraintTitleLabel : NSLayoutConstraint!
    
    var isLowTicketsCount: Int! {
        didSet {
            if isLowTicketsCount == 0 {
                lowTicketsCount.isHidden = true
            } else if isLowTicketsCount < 3 {
                lowTicketsCount.isHidden = false
            } else {
                lowTicketsCount.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ticketLabel.font = UIFont(name: "MoscowSans-Bold", size: 20)
        lowTicketsCount.font = UIFont(name: "MoscowSans-Regular", size: 15)
    }
    
    public func configure(with data: _TicketsHeader) {
        isLowTicketsCount = data.ticketsCount
        ticketLabel.text = data.title
        leftConstraintTitleLabel.constant = data.isInsetGroup ? 20 : 10
    }
}
