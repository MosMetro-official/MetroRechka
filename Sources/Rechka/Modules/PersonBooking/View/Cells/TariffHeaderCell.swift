//
//  TariffHeaderCell.swift
//  
//
//  Created by Слава Платонов on 24.03.2022.
//

import UIKit
import CoreTableView

protocol _TariffHeaderCell: CellData { }

extension _TariffHeaderCell {
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(TariffHeaderCell.nib, forCellReuseIdentifier: TariffHeaderCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TariffHeaderCell.identifire, for: indexPath) as? TariffHeaderCell else { return .init() }
        return cell
    }
}

class TariffHeaderCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont(name: "MoscowSans-Bold", size: 20)
    }
}
