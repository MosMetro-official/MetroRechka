//
//  DocumentCell.swift
//  
//
//  Created by Слава Платонов on 11.04.2022.
//

import UIKit
import CoreTableView

protocol _Document: CellData {
    var title: String { get }
    var onSelect: () -> Void { get }
}

extension _Document {
    
    var height: CGFloat {
        return 65
    }
    
    func hashValues() -> [Int] {
        return [title.hashValue]
    }
    
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

    @IBOutlet weak var documentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with data: _Document) {
        documentLabel.text = data.title
    }
    
}
