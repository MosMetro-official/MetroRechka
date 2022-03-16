//
//  MapViewCell.swift
//  
//
//  Created by Слава Платонов on 16.03.2022.
//

import UIKit
import CoreTableView

protocol _MapView: CellData {
    var onButtonSelect: () -> () { get }
}

extension _MapView {
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? MapViewCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(MapViewCell.nib, forCellReuseIdentifier: MapViewCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MapViewCell.identifire, for: indexPath) as? MapViewCell else { return .init() }
        return cell
    }
}

class MapViewCell: UITableViewCell {
    
    var onSelect: (() -> ())!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var mapImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mapButton.layer.cornerRadius = 20
        mapImage.layer.cornerRadius = 10
        let customButtonTitle = NSMutableAttributedString(string: " Маршрут на карте", attributes: [
            NSAttributedString.Key.font: UIFont.customFont(forTextStyle: .caption1),
        ])
        mapButton.setAttributedTitle(customButtonTitle, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.bounds.inset(by: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
    }
    
    @IBAction func onMapButtonTapped() {
        onSelect()
    }
    
    public func configure(with data: _MapView) {
        onSelect = data.onButtonSelect
    }
    
}
