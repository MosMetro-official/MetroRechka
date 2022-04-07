//
//  TimerCell.swift
//  
//
//  Created by polykuzin on 24/03/2022.
//

import UIKit
import CoreTableView

protocol _Timer : CellData {
    var timer : String { get }
    var descr : String { get }
}

extension _Timer {
    
    var height : CGFloat {
        return 230
    }
    
    func hashValues() -> [Int] {
        return [
            timer.hashValue,
            descr.hashValue
        ]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? TimerCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(TimerCell.nib, forCellReuseIdentifier: TimerCell.identifire)
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: TimerCell.identifire, for: indexPath) as? TimerCell
        else { return .init() }
        return cell
    }
}

class TimerCell : UITableViewCell {
    
    @IBOutlet private weak var timer : UILabel!
    @IBOutlet private weak var descr : UILabel!
    
    public func configure(with data: _Timer) {
        self.timer.text = data.timer
        self.descr.text = data.descr
    }
}
