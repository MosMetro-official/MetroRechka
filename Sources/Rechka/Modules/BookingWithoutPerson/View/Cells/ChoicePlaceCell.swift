//
//  ChoicePlaceCell.swift
//  
//
//  Created by Слава Платонов on 25.03.2022.
//

import UIKit
import CoreTableView

protocol _ChoicePlace: CellData {
    var title: String { get }
    var onItemSelect: Command<Void> { get }
}

extension _ChoicePlace {
    
    var height: CGFloat {
        return 60
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? ChoicePlaceCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(ChoicePlaceCell.nib, forCellReuseIdentifier: ChoicePlaceCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChoicePlaceCell.identifire, for: indexPath) as? ChoicePlaceCell else { return .init() }
        return cell
    }
}

class ChoicePlaceCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }
    
    func configure(with data: _ChoicePlace) {
        self.titleLabel.text = data.title
    }
}
