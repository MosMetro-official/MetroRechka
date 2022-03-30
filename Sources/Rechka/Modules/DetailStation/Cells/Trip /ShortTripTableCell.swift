//
//  ShortTripTableCell.swift
//  
//
//  Created by guseyn on 29.03.2022.
//

import UIKit
import CoreTableView



protocol _ShortTripTableCell: CellData {
    
    var date: String { get }
    var isSelected: Bool { get }
    var price: String { get }
    var seats: String { get }
    
}

extension _ShortTripTableCell {
    
    var height: CGFloat {
        return 120
    }
    
    func hashValues() -> [Int] {
        return [date.hashValue,isSelected.hashValue,price.hashValue,seats.hashValue]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? ShortTripTableCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: ShortTripTableCell.identifire, bundle: .module), forCellReuseIdentifier: ShortTripTableCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShortTripTableCell.identifire, for: indexPath) as? ShortTripTableCell else { return .init() }
        return cell
    }
}

class ShortTripTableCell: UITableViewCell {

    @IBOutlet private weak var cardView: UIView!
    
    @IBOutlet private weak var rightImageView: UIImageView!
    
    @IBOutlet private weak var dateLabek: UILabel!
    
    @IBOutlet private weak var priceLabel: UILabel!
    
    @IBOutlet private weak var seatsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cardView.layer.cornerRadius = 12
        self.cardView.layer.cornerCurve = .continuous
        self.cardView.layer.borderWidth = 0.5
        self.cardView.layer.borderColor = Appearance.colors[.textSecondary]?.cgColor
        self.dateLabek.font = Appearance.customFonts[.body]
        self.priceLabel.font = Appearance.customFonts[.footnote]
        self.seatsLabel.font = Appearance.customFonts[.footnote]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with data: _ShortTripTableCell) {
        self.dateLabek.text = data.date
        self.priceLabel.text = data.price
        self.seatsLabel.text = data.seats
        self.cardView.layer.borderWidth = data.isSelected ? 1.5 : 0.5
        
    }
    
}
