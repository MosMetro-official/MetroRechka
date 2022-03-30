//
//  TariffCell.swift
//  
//
//  Created by Слава Платонов on 24.03.2022.
//

import UIKit
import CoreTableView

protocol _Tariff: CellData {
    var tariffs: String { get }
    var price: String { get }
}

extension _Tariff {
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? TariffCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(TariffCell.nib, forCellReuseIdentifier: TariffCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TariffCell.identifire, for: indexPath) as? TariffCell else { return .init() }
        return cell
    }
}

class TariffCell: UITableViewCell {

    @IBOutlet weak var tariffsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tariffsLabel.font = UIFont(name: "MoscowSans-Regular", size: 17)
        priceLabel.font = UIFont(name: "MoscowSans-Regular", size: 17)
    }
    
    public func configure(with data: _Tariff) {
        tariffsLabel.text = data.tariffs
        priceLabel.text = data.price
    }
}
