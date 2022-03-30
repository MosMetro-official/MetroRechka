//
//  TicketStatusCell.swift
//  
//
//  Created by polykuzin on 29/03/2022.
//

import UIKit
import CoreTableView

enum PurchaseStatus {
    case denied
    case success
    case waitnig
}

protocol _TicketStatus : CellData {
    var title : String { get }
    var status : PurchaseStatus {  get }
}

extension _TicketStatus {
    
    var height: CGFloat {
        return 125
    }
    
    func hashValues() -> [Int] {
        return [
            title.hashValue,
            status.hashValue
        ]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? TicketStatusCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: TicketStatusCell.identifire, bundle: .module), forCellReuseIdentifier: TicketStatusCell.identifire)
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TicketStatusCell.identifire, for: indexPath) as? TicketStatusCell
        else { return .init() }
        return cell
    }
}

class TicketStatusCell: UITableViewCell {
    
    public func configure(with data: _TicketStatus) {
        title.text = data.title
        switch data.status {
        case .denied :
            status.image = UIImage(named: "result_error", in: .module, compatibleWith: nil)
        case .success :
            status.image = UIImage(named: "checkmark", in: .module, compatibleWith: nil)
        case .waitnig :
            status.image = UIImage(named: "payment_waiting", in: .module, compatibleWith: nil)
        }
    }
    
    @IBOutlet private weak var title : UILabel!
    
    @IBOutlet private weak var status : UIImageView!
}
