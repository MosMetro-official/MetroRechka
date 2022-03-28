//
//  TitleCell.swift
//  
//
//  Created by polykuzin on 24/03/2022.
//

import UIKit
import CoreTableView

protocol _Title : CellData {
    var title : String { get }
}

extension _Title {
    
    var height : CGFloat {
        return 70
    }
    
    func hashValues() -> [Int] {
        return [
            title.hashValue
        ]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? TitleCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(TitleCell.nib, forCellReuseIdentifier: TitleCell.identifire)
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TitleCell.identifire, for: indexPath) as? TitleCell
        else { return .init() }
        return cell
    }
}

class TitleCell : UITableViewCell {
    
    @IBOutlet private weak var title : UILabel!
    
    public func configure(with data: _Title) {
        self.title.text = data.title
    }
}
