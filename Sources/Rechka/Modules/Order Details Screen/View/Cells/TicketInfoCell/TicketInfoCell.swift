//
//  TicketInfoCell.swift
//  
//
//  Created by polykuzin on 29/03/2022.
//

import UIKit
import CoreTableView

protocol _TicketInfo : CellData {
    var title : String { get }
    var descr : String { get }
    var image : UIImage { get }
}

extension _TicketInfo {
    
    func hashValues() -> [Int] {
        return [
            title.hashValue,
            descr.hashValue
        ]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? TicketInfoCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: TicketInfoCell.identifire, bundle: Rechka.shared.bundle), forCellReuseIdentifier: TicketInfoCell.identifire)
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TicketInfoCell.identifire, for: indexPath) as? TicketInfoCell
        else { return .init() }
        return cell
    }
}

class TicketInfoCell : UITableViewCell {
    
    @IBOutlet private weak var title : UILabel!
    @IBOutlet private weak var descr : UILabel!
    @IBOutlet private weak var leftImage : UIImageView!
    
    public func configure(with data: _TicketInfo) {
        title.text = data.title
        descr.text = data.descr
        leftImage.image = data.image
    }
}
