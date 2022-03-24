//
//  DocumentCell.swift
//  
//
//  Created by Слава Платонов on 23.03.2022.
//

import UIKit
import CoreTableView

protocol _Document: CellData {
    var title: String { get }
    var onSelect: () -> () { get }
}

extension _Document {
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? DocumentCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(DocumentCell.nib, forCellReuseIdentifier: DocumentCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DocumentCell.identifire, for: indexPath) as? DocumentCell else { return .init() }
        return cell
    }
}

class DocumentCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font = UIFont(name: "MoscowSans-Bold", size: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with data: _Document) {
        titleLabel.text = data.title
    }
}
