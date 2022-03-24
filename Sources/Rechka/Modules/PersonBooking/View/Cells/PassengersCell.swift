//
//  PassengersCell.swift
//  
//
//  Created by Слава Платонов on 24.03.2022.
//

import UIKit
import CoreTableView

protocol _Passenger: CellData {
    var name: String { get }
    var tariff: String { get }
}

extension _Passenger {
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? PassengersCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(PassengersCell.nib, forCellReuseIdentifier: PassengersCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PassengersCell.identifire, for: indexPath) as? PassengersCell else { return .init() }
        return cell
    }
}

class PassengersCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tariffLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = UIFont(name: "MoscowSans-Regular", size: 17)
        tariffLabel.font = UIFont(name: "MoscowSans-Regular", size: 13)
    }
    
    public func configure(with data: _Passenger) {
        nameLabel.text = data.name
        tariffLabel.text = data.tariff
    }
}
