//
//  CitizenshipCell.swift
//  
//
//  Created by Слава Платонов on 23.03.2022.
//

import UIKit
import CoreTableView

protocol _Citizen: CellData {
    var title: String { get }
    var onSelect: () -> () { get }
}

extension _Citizen {
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? CitizenshipCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(CitizenshipCell.nib, forCellReuseIdentifier: CitizenshipCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CitizenshipCell.identifire, for: indexPath) as? CitizenshipCell else { return .init() }
        return cell
    }
}

class CitizenshipCell: UITableViewCell {
    
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
    
    public func configure(with data: _Citizen) {
        titleLabel.text = data.title
    }
}
