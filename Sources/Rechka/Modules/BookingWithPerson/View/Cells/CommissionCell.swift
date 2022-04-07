//
//  CommissionCell.swift
//  
//
//  Created by Слава Платонов on 24.03.2022.
//

import UIKit
import CoreTableView

protocol _Commission: CellData {
    var price: String { get }
    var commission: String { get }
}

extension _Commission {
    
    var height: CGFloat {
        return 60
    }
    
    func hashValues() -> [Int] {
        return [price.hashValue, commission.hashValue]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? CommissionCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(CommissionCell.nib, forCellReuseIdentifier: CommissionCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommissionCell.identifire, for: indexPath) as? CommissionCell else { return .init() }
        return cell
    }
}

class CommissionCell: UITableViewCell {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var commissionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        priceLabel.font = UIFont(name: "MoscowSans-Regular", size: 17)
        commissionLabel.font = UIFont(name: "MoscowSans-Regular", size: 17)
    }

    public func configure(with data: _Commission) {
        priceLabel.text = data.price
        commissionLabel.text = data.commission
    }
    
    @IBAction func infoButtonTapped() {
        
    }
}
