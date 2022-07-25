//
//  PassengerHeader.swift
//  
//
//  Created by Слава Платонов on 24.03.2022.
//

import UIKit
import CoreTableView

protocol _PassengerHeaderCell: CellData {
    var newUserAvailable: Bool { get }
    var menuActions: [UIAction] { get }
    var onAdd: () -> () { get }
}

extension _PassengerHeaderCell {
    
    var height: CGFloat {
        return 50
    }
    
    func hashValues() -> [Int] {
        return []
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? PassengerHeaderCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(PassengerHeaderCell.nib, forCellReuseIdentifier: PassengerHeaderCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PassengerHeaderCell.identifire, for: indexPath) as? PassengerHeaderCell else { return .init() }
        return cell
    }
}

class PassengerHeaderCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func configure(with data: _PassengerHeaderCell) {
        if data.newUserAvailable {
            if #available(iOS 14.0, *) {
                addButton.menu = UIMenu(title: "Пассажиры", children: data.menuActions)
                addButton.showsMenuAsPrimaryAction = true
            } else {
                data.onAdd()
            }
        }
    }
}
