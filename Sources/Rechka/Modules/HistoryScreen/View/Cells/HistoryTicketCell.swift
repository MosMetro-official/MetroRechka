//
//  HistoryTicketCell.swift
//  
//
//  Created by Слава Платонов on 29.03.2022.
//

import UIKit
import CoreTableView

protocol _History: CellData {
    var title : String { get }
    var descr : String { get }
    var price : String { get }
}

extension _History {
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? HistoryTicketCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(HistoryTicketCell.nib, forCellReuseIdentifier: HistoryTicketCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTicketCell.identifire, for: indexPath) as? HistoryTicketCell else { return .init() }
        return cell
    }
}

class HistoryTicketCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont(name: "MoscowSans-Regular", size: 17)
        priceLabel.font = UIFont(name: "MoscowSans-Regular", size: 17)
        descriptionLabel.font = UIFont(name: "MoscowSans-Regular", size: 13)
    }
    
    public func configure(with data: _History) {
        titleLabel.text = data.title
        descriptionLabel.text = data.descr
        priceLabel.text = data.price
    }
}
