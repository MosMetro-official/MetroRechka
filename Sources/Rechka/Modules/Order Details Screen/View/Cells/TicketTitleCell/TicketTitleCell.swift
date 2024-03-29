//
//  TicketTitleCell.swift
//  
//
//  Created by polykuzin on 29/03/2022.
//

import UIKit
import CoreTableView

protocol _TicketTitle : CellData {
    var title : String { get }
}

extension _TicketTitle {
    
    var height: CGFloat {
        return 46
    }
    
    func hashValues() -> [Int] {
        return [
            title.hashValue
        ]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? TicketTitleCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: TicketTitleCell.identifire, bundle: Rechka.shared.bundle), forCellReuseIdentifier: TicketTitleCell.identifire)
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TicketTitleCell.identifire, for: indexPath) as? TicketTitleCell
        else { return .init() }
        return cell
    }
}

class TicketTitleCell: UITableViewCell {
    
    @IBOutlet private weak var title : UILabel!
    
    public func configure(with data: _TicketTitle) {
        title.text = data.title
    }
}
