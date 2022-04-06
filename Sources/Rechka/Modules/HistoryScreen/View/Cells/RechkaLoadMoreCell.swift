//
//  RechkaLoadMoreCell.swift
//  
//
//  Created by guseyn on 05.04.2022.
//

import UIKit
import CoreTableView

protocol _RechkaLoadMoreCell: CellData {
    var onLoad: Command<Void>? { get }
}

extension _RechkaLoadMoreCell {
    
    var height: CGFloat {
        return 56
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? RechkaLoadMoreCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(RechkaLoadMoreCell.nib, forCellReuseIdentifier: RechkaLoadMoreCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RechkaLoadMoreCell.identifire, for: indexPath) as? RechkaLoadMoreCell else { return .init() }
        return cell
    }
    
}

class RechkaLoadMoreCell: UITableViewCell {

    
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingButton: UIButton!
    
    private var onLoad: Command<Void>?
    
    @IBAction private func handleLoad(_ sender: UIButton) {
        onLoad?.perform(with: ())
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with data: _RechkaLoadMoreCell) {
        self.loadingButton.isHidden = data.onLoad == nil
        self.loadingIndicator.isHidden = data.onLoad != nil
        self.loadingIndicator.startAnimating()
        self.onLoad = data.onLoad
    }
    
}
