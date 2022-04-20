//
//  PassengerHeader.swift
//  
//
//  Created by Слава Платонов on 24.03.2022.
//

import UIKit
import CoreTableView

protocol _PassengerHeaderCell: CellData {
    var onAdd: () -> () { get }
}

extension _PassengerHeaderCell {
    
    var height: CGFloat {
        return 50
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
    var onAdd: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func configure(with data: _PassengerHeaderCell) {
        onAdd = data.onAdd
    }
    
    @IBAction func onAddButtonTapped() {
        onAdd?()
    }
}
