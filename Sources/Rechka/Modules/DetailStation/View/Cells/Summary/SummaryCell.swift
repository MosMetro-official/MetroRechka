//
//  SummaryCell.swift
//  
//
//  Created by Слава Платонов on 16.03.2022.
//

import UIKit
import CoreTableView

protocol _Suumary: CellData {
    var duration: String { get }
    var fromTo: String { get }
}

extension _Suumary {
    public func hashValues() -> [Int] {
        return [duration.hashValue, fromTo.hashValue]
    }
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? SummaryCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: SummaryCell.identifire, bundle: .module), forCellReuseIdentifier: SummaryCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SummaryCell.identifire, for: indexPath) as? SummaryCell else { return .init() }
        return cell
    }
}

class SummaryCell: UITableViewCell {

    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var fromToLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        durationLabel.font = UIFont(name: "MoscowSans-Regular", size: 19)
        fromToLabel.font = UIFont(name: "MoscowSans-Regular", size: 17)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.bounds.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
    }
    
    public func configure(with data: _Suumary) {
        durationLabel.text = data.duration
        fromToLabel.text = data.fromTo
    }
    
}
