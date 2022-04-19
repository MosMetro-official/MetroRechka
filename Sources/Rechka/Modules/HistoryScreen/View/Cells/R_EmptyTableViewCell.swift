//
//  R_EmptyTableViewCell.swift
//  
//
//  Created by Гусейн on 19.04.2022.
//

import UIKit
import CoreTableView

protocol _R_EmptyTableViewCell: CellData {
    var title: String { get set }
    var image: UIImage { get set }
}

extension _R_EmptyTableViewCell {
    
    var height: CGFloat {
        return UIScreen.main.bounds.height / 2
    }
    
    func hashValues() -> [Int] {
        return [title.hashValue,image.hashValue]
    }
    
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? R_EmptyTableViewCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(R_EmptyTableViewCell.nib, forCellReuseIdentifier: R_EmptyTableViewCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R_EmptyTableViewCell.identifire, for: indexPath) as? R_EmptyTableViewCell else {
            return .init()
        }
        return cell
    }
    
}

class R_EmptyTableViewCell: UITableViewCell {

    @IBOutlet private var mainImageView: UIImageView!
    
    @IBOutlet private var mainTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with data: _R_EmptyTableViewCell) {
        self.mainTitleLabel.text = data.title
        self.mainImageView.image = data.image
    }
    
}
