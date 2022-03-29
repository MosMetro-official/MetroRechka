//
//  SelectCell.swift
//  
//
//  Created by Слава Платонов on 28.03.2022.
//

import UIKit
import CoreTableView

protocol _SelectCell: CellData {
    var title: String { get }
    var onSelect: () -> () { get }
}

extension _SelectCell {
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? SelectCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(SelectCell.nib, forCellReuseIdentifier: SelectCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectCell.identifire, for: indexPath) as? SelectCell else { return .init() }
        return cell
    }
}

class SelectCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont(name: "MoscowSans-Regular", size: 17)
    }
    
    public func configure(with data: _SelectCell) {
        titleLabel.text = data.title
    }
    
}
