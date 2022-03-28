//
//  CancelCell.swift
//  
//
//  Created by polykuzin on 24/03/2022.
//

import UIKit
import CoreTableView

protocol _Cancel : CellData {
    var title : String { get }
}

extension _Cancel {
    
    var height : CGFloat {
        return 48
    }
    
    func hashValues() -> [Int] {
        return [
            title.hashValue
        ]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? CancelCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(CancelCell.nib, forCellReuseIdentifier: CancelCell.identifire)
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: CancelCell.identifire, for: indexPath) as? CancelCell
        else { return .init() }
        return cell
    }
}

class CancelCell : UITableViewCell {
    
    @IBOutlet private weak var cancelButton : UILabel!
    
    public func configure(with data: _Cancel) {
        self.cancelButton.text = data.title
//        self.cancelButton.textColor = UIColor.custom(for: .emptyTicketsLayer)
    }
}
