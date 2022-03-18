//
//  PackageCell.swift
//  
//
//  Created by Слава Платонов on 16.03.2022.
//

import UIKit
import CoreTableView

protocol _Package: CellData { }

extension _Package {
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(PackageCell.nib, forCellReuseIdentifier: PackageCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PackageCell.identifire, for: indexPath) as? PackageCell else { return .init() }
        return cell
    }
}

class PackageCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private let text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 10
        descriptionLabel.text = text
        descriptionLabel.font = UIFont(name: "MoscowSans-Regular", size: 17)
    }    
}
