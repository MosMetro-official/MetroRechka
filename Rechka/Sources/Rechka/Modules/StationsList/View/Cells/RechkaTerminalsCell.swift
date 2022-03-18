//
//  RechkaTerminalsCell.swift
//  
//
//  Created by polykuzin on 16/03/2022.
//

import UIKit
import CoreTableView

protocol _TerminalCell : _RechkaTerminal, CellData {
    
}

extension _TerminalCell {
    
    var height : CGFloat {
        return 61
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard
            let cell = cell as? RechkaTerminalsCell
        else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(RechkaTerminalsCell.nib, forCellReuseIdentifier: RechkaTerminalsCell.identifire)
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: RechkaTerminalsCell.identifire, for: indexPath) as? RechkaTerminalsCell
        else { return .init() }
        return cell
    }
}

class RechkaTerminalsCell : UITableViewCell {

    @IBOutlet private weak var title : UILabel!
    @IBOutlet private weak var descr : UILabel!
    @IBOutlet private weak var shipImage : UIImageView!
    
    public func configure(with data: _TerminalCell) {
        self.title.text = data.title
        self.descr.text = data.descr
    }
}
