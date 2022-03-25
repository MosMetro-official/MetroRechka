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
    var price: String { get set }
    var stepperCount: String { get set }
    var onPlus: (Int) -> () { get set }
    var onMinus: (Int) -> () { get set }
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
        return stepperLabel.text == "0"
    }
    lazy var currentCount = Int(stepperLabel.text ?? "1")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stepperView.layer.cornerRadius = 6
    }
    
    public func configure(with data: _TariffSteper) {
        tariffLabel.text = data.tariff
        priceLabel.text = data.price
        stepperLabel.text = data.stepperCount
        onPlus = data.onPlus
        onMinus = data.onMinus
        minusButton.alpha = enableMinus ? 0.3 : 1
    }
    
    @IBAction func minusButtonTapped() {
        let count = Int(stepperLabel.text ?? "0")
        stepperLabel.text = String((count ?? 0) - 1)
        onMinus?(currentCount ?? 0)
    }
    
    @IBAction func plusButtonTapped() {
        let count = Int(stepperLabel.text ?? "0")
        stepperLabel.text = String((count ?? 0) + 1)
        onPlus?(currentCount ?? 0)
    }
}
