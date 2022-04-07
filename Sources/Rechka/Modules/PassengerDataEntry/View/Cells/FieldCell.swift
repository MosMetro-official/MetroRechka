//
//  FieldCell.swift
//  
//
//  Created by Слава Платонов on 23.03.2022.
//

import UIKit
import CoreTableView

protocol _Field: CellData {
    var text: String { get }
    var onSelect: () -> () { get }
}

extension _Field {
    
    var height: CGFloat {
        return 50
    }
    
    func hashValues() -> [Int] {
        return [text.hashValue]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? FieldCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(FieldCell.nib, forCellReuseIdentifier: FieldCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FieldCell.identifire, for: indexPath) as? FieldCell else { return .init() }
        return cell
    }
}

class FieldCell: UITableViewCell {
    
    @IBOutlet weak var mainTextLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure(with data: _Field) {
        mainTextLabel.text = data.text
        
    }
}
