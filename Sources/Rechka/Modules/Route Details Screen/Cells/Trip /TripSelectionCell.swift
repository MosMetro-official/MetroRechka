//
//  TripSelectionCell.swift
//  
//
//  Created by guseyn on 13.04.2022.
//

import UIKit
import CoreTableView

protocol _TripSelectionCell: CellData {
    
    var day: String { get }
    var items: [_R_DateCollectionCell] { get }
    var shouldScrollToInitial: Bool { get }
    
}

extension _TripSelectionCell {
    
    var height: CGFloat {
        return 80
    }
    
    func hashValues() -> [Int] {
        return [day.hashValue]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? TripSelectionCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: TripSelectionCell.identifire, bundle: Rechka.shared.bundle), forCellReuseIdentifier: TripSelectionCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TripSelectionCell.identifire, for: indexPath) as? TripSelectionCell else { return .init() }
        return cell
    }
    
    
}

class TripSelectionCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateView: UIView!
    
    private var leftGradient: CAGradientLayer?
    private var rightGradient: CAGradientLayer?
    
    private var items: [_R_DateCollectionCell] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        collectionView.register(R_DateCollectionCell.nib, forCellWithReuseIdentifier: R_DateCollectionCell.identifire)
        addGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let rightGradient = rightGradient else {
            return
        }
        guard let leftGradient = leftGradient else {
            return
        }
        leftGradient.endPoint = CGPoint(x: 0, y: 1)
        leftGradient.startPoint = CGPoint(x: 1, y: 1)
        rightGradient.endPoint = CGPoint(x: 1, y: 1)
        rightGradient.startPoint = CGPoint(x: 0, y: 1)
        let base = Appearance.colors[.base] ?? UIColor.systemBackground
        leftGradient.colors = [base.withAlphaComponent(0).cgColor, base.cgColor]
        leftGradient.frame = CGRect(origin: CGPoint(x: 76, y: 12), size: .init(width: 8, height: 56))
        rightGradient.colors = [base.withAlphaComponent(0).cgColor, base.cgColor]
        rightGradient.frame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.width - 20, y: 12), size: .init(width: 20, height: 56))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    private func addGradient() {
        self.leftGradient = CAGradientLayer()
        self.rightGradient = CAGradientLayer()
        guard let leftGradient = leftGradient, let rightGradient = rightGradient else { return }

        let base = Appearance.colors[.base] ?? UIColor.systemBackground
        
        leftGradient.frame =  CGRect(origin: CGPoint(x: 76, y: 12), size: .init(width: 8, height: 56))
        leftGradient.colors = [base.cgColor, base.withAlphaComponent(0).cgColor]
        leftGradient.startPoint = CGPoint(x: 1, y: 1)
        leftGradient.endPoint = CGPoint(x: 0, y: 1)
        
        rightGradient.frame =  CGRect(origin: CGPoint(x: UIScreen.main.bounds.width - 20, y: 12), size: .init(width: 20, height: 56))
        rightGradient.colors = [base.withAlphaComponent(0).cgColor,base.cgColor]
        rightGradient.startPoint = CGPoint(x: 0, y: 1)
        rightGradient.endPoint = CGPoint(x: 1, y: 1)
      
        self.layer.addSublayer(leftGradient)
        self.layer.addSublayer(rightGradient)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with data: _TripSelectionCell) {
        self.dateLabel.text = data.day
        self.items = data.items

    }
    
}

extension TripSelectionCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let element = self.items[safe: indexPath.item] else { return .init() }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R_DateCollectionCell.identifire, for: indexPath) as? R_DateCollectionCell else { return .init() }
        cell.configure(with: element)
        return cell
    }
      
}

extension TripSelectionCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let element = self.items[safe: indexPath.item] else { return }
        element.onSelect.perform(with: ())
    }
    
}

extension TripSelectionCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 64, height: 36)
    }
}
