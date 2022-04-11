//
//  R_ErrorCell.swift
//  
//
//  Created by guseyn on 09.04.2022.
//

import UIKit
import CoreTableView

protocol _R_ErrorCell: CellData {
    var image: UIImage { get }
    var title: String { get }
    var action: Command<Void>? { get }
    var buttonTitle: String? { get }
}


extension _R_ErrorCell {
    public func hashValues() -> [Int] {
        return [title.hashValue]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? R_ErrorCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: R_ErrorCell.identifire, bundle: .module), forCellReuseIdentifier: R_ErrorCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R_ErrorCell.identifire, for: indexPath) as? R_ErrorCell else { return .init() }
        return cell
    }
}


class R_ErrorCell: UITableViewCell {

    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var errorImageView: UIImageView!
    
    @IBOutlet private weak var retryButton: UIButton!
    
    private var action: Command<Void>?
    
    
    @IBAction func handleButtonTap(_ sender: UIButton) {
        action?.perform(with: ())
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        retryButton.roundCorners(.all, radius: 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with data: _R_ErrorCell) {
        self.errorLabel.text = data.title
        self.errorImageView.image = data.image
        self.retryButton.isHidden = data.action == nil
        self.retryButton.setTitle(data.buttonTitle, for: .normal)
        self.action = data.action
    }
    
}
