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
    
    private var gradient: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cardView.layer.cornerRadius = 12
        //self.cardView.layer.cornerCurve = .continuous
        self.cardView.layer.borderWidth = 0.5
        self.cardView.layer.borderColor = Appearance.colors[.textSecondary]?.cgColor
        self.dateLabek.font = Appearance.customFonts[.body]
        self.priceLabel.font = Appearance.customFonts[.footnote]
        self.seatsLabel.font = Appearance.customFonts[.footnote]
        addGradient()
    }
    
    private func addGradient() {
        self.gradient = CAGradientLayer()
        guard let gradient = gradient else {
            return
        }
        gradient.frame =  CGRect(origin: CGPoint(x: 20, y: 8), size: .init(width: UIScreen.main.bounds.width - 40, height: 104))
        gradient.colors = [UIColor.from(hex: "#4AC7FA").cgColor, UIColor.from(hex: "#E649F5").cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        let shape = CAShapeLayer()
        shape.lineWidth = 1.5
        shape.path =  UIBezierPath(roundedRect: CGRect(origin: .zero, size: gradient.frame.size).insetBy(dx: 1.5, dy: 1.5), cornerRadius: 12).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        self.layer.addSublayer(gradient)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with data: _ShortTripTableCell) {
        self.dateLabek.text = data.date
        self.priceLabel.text = data.price
        self.seatsLabel.text = data.seats
        self.cardView.layer.borderWidth = data.isSelected ? 0 : 0.5
        self.gradient?.isHidden = data.isSelected ? false : true
    }
    
}
