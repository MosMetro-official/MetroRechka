//
//  StaticCell.swift
//  
//
//  Created by Слава Платонов on 23.03.2022.
//

import UIKit
import CoreTableView

protocol _Static: CellData {
    var title: String { get }
}

extension _Static {
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? StaticCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(StaticCell.nib, forCellReuseIdentifier: StaticCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StaticCell.identifire, for: indexPath) as? StaticCell else { return .init() }
        return cell
    }
}

class StaticCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont(name: "MoscowSans-Bold", size: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with data: _Static) {
        titleLabel.text = data.title
    }
    
}
