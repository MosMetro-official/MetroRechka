//
//  TariffSteperCell.swift
//  
//
//  Created by Слава Платонов on 25.03.2022.
//

import UIKit
import CoreTableView

protocol _TariffSteper: CellData {
    var tariff: String { get }
    var price: String { get }
    var stepperCount: String { get }
    var onPlus: (Int) -> () { get }
    var onMinus: (Int) -> () { get }
}

extension _TariffSteper {
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? TariffSteperCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(TariffSteperCell.nib, forCellReuseIdentifier: TariffSteperCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TariffSteperCell.identifire, for: indexPath) as? TariffSteperCell else { return .init() }
        return cell
    }
}

class TariffSteperCell: UITableViewCell {
    
    @IBOutlet weak var stepperView: UIView!
    @IBOutlet weak var stepperLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var tariffLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var onPlus: ((Int) -> ())?
    var onMinus: ((Int) -> ())?
    var enableMinus: Bool {
        return currentCount > 0
    }
    private var currentCount: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stepperView.layer.cornerRadius = 8
        minusButton.isEnabled = false
        minusButton.alpha = 0.3
        stepperLabel.font = UIFont(name: "MoscowSans-Regular", size: 15)
        tariffLabel.font = UIFont(name: "MoscowSans-Regular", size: 17)
        priceLabel.font = UIFont(name: "MoscowSans-Regular", size: 13)
    }
    
    public func configure(with data: _TariffSteper) {
        tariffLabel.text = data.tariff
        priceLabel.text = data.price
        stepperLabel.text = data.stepperCount
        onPlus = data.onPlus
        onMinus = data.onMinus
    }
    
    @IBAction func minusButtonTapped() {
        if enableMinus {
            currentCount -= 1
            stepperLabel.text = String(currentCount)
            onMinus?(currentCount)
            if currentCount == 0 {
                disableMinus()
            }
        }
    }
    
    @IBAction func plusButtonTapped() {
        currentCount += 1
        stepperLabel.text = String(currentCount)
        onPlus?(currentCount)
        if currentCount != 0 {
            enableMinuse()
        }
    }
    
    private func disableMinus() {
        minusButton.isEnabled = false
        minusButton.alpha = 0.3
    }
    
    private func enableMinuse() {
        minusButton.isEnabled = true
        minusButton.alpha = 1
    }
}
