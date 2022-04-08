//
//  R_OrderPaymentTableViewCell.swift
//  
//
//  Created by guseyn on 06.04.2022.
//

import UIKit
import CoreTableView


protocol _R_OrderPaymentTableViewCell: CellData {
    
    var onPay: Command<Void> { get }
    var time: String { get }
    var desc: String { get }
    
}

extension _R_OrderPaymentTableViewCell {
    
    var height: CGFloat {
        return 64
    }
    
    func hashValues() -> [Int] {
        return [time.hashValue,desc.hashValue]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? R_OrderPaymentTableViewCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: R_OrderPaymentTableViewCell.identifire, bundle: .module), forCellReuseIdentifier: R_OrderPaymentTableViewCell.identifire)
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: R_OrderPaymentTableViewCell.identifire, for: indexPath) as? R_OrderPaymentTableViewCell
        else { return .init() }
        return cell
    }
    
}

class R_OrderPaymentTableViewCell: UITableViewCell {

    @IBOutlet weak var payButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    private var onPay: Command<Void>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func handlePay(_ sender: UIButton) {
        onPay?.perform(with: ())
        
        
    }
    
    public func configure(with data: _R_OrderPaymentTableViewCell) {
        self.descLabel.text = data.desc
        self.timeLabel.text = data.time
        self.onPay = data.onPay
    }
    
}
