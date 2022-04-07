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
    var onPlus: Command<Void>? { get }
    var onMinus: Command<Void>? { get }
}

extension _TariffSteper {
    
    var height: CGFloat {
        return 87
    }
    
    func hashValues() -> [Int] {
        return [tariff.hashValue,price.hashValue,stepperCount.hashValue]
    }
    
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
    
    @IBOutlet private weak var stepperView: UIView!
    @IBOutlet private weak var stepperLabel: UILabel!
    @IBOutlet private weak var minusButton: UIButton!
    @IBOutlet private weak var tariffLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    
    @IBOutlet weak var plusButton: UIButton!
    private var onPlus: Command<Void>?
    private var onMinus: Command<Void>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stepperView.layer.cornerRadius = 8
        stepperView.layer.cornerCurve = .continuous
    }
    
    public func configure(with data: _TariffSteper) {
        tariffLabel.text = data.tariff
        priceLabel.text = data.price
        stepperLabel.text = data.stepperCount
        minusButton.alpha = data.onMinus == nil ? 0.3 : 1
        plusButton.alpha = data.onPlus == nil ? 0.3 : 1
        onPlus = data.onPlus
        onMinus = data.onMinus
    }
    
    @IBAction func minusButtonTapped() {
        onMinus?.perform(with: ())
    }
    
    @IBAction func plusButtonTapped() {
        onPlus?.perform(with: ())
    } 
}
