//
//  StaticCell.swift
//  
//
//  Created by Слава Платонов on 23.03.2022.
//

import UIKit
import CoreTableView

protocol _HeaderCell: CellData {
    var title: String { get }
}

extension _HeaderCell {
    
    var height: CGFloat {
        return 50
    }
    
    func hashValues() -> [Int] {
        return [title.hashValue]
    }

    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? HeaderCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(HeaderCell.nib, forCellReuseIdentifier: HeaderCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HeaderCell.identifire, for: indexPath) as? HeaderCell else { return .init() }
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        return cell
    }
}

class HeaderCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with data: _HeaderCell) {
        titleLabel.text = data.title
    }
    
}
