//
//  CitizenshipCell.swift
//  
//
//  Created by Слава Платонов on 11.04.2022.
//

import UIKit
import CoreTableView

protocol _Citizenship: CellData {
    var title: String { get }
    var onSelect: () -> Void { get }
}

extension _Citizenship {
    
    var height: CGFloat {
        return 50
    }
    
    func hashValues() -> [Int] {
        return [title.hashValue]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? CitizenshipCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(CitizenshipCell.nib, forCellReuseIdentifier: CitizenshipCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CitizenshipCell.identifire, for: indexPath) as? CitizenshipCell else { return .init() }
        return cell
    }
}

class CitizenshipCell: UITableViewCell {
    
    @IBOutlet weak var citizenshipLabel: UILabel!
    
    public func configure(with data: _Citizenship) {
        citizenshipLabel.text = data.title
    }
}
