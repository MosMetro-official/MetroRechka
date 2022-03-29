//
//  GenderCell.swift
//  
//
//  Created by Слава Платонов on 23.03.2022.
//

import UIKit
import CoreTableView

protocol _Gender: CellData {
    var gender: Gender { get }
    var onTap: (Gender) -> () { get }
}

extension _Gender {
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? GenderCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(GenderCell.nib, forCellReuseIdentifier: GenderCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GenderCell.identifire, for: indexPath) as? GenderCell else { return .init() }
        return cell
    }
}

class GenderCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentControll: UISegmentedControl!
    
    private var onGenderSelect: ((Gender) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font = UIFont(name: "MoscowSans-Regular", size: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func handleSegment(_ sender: UISegmentedControl) {
        onGenderSelect?(sender.selectedSegmentIndex == 0 ? .male : .female)
    }
    
    public func configure(with data: _Gender) {
        onGenderSelect = data.onTap
    }
    
}
