//
//  SummaryCell.swift
//  
//
//  Created by Слава Платонов on 16.03.2022.
//

import UIKit
import CoreTableView

protocol _Summary: CellData {
    var text: NSAttributedString { get }
    var onMore: Command<Void>? { get }
}

extension _Summary {
    
    
    public func hashValues() -> [Int] {
        return [text.hashValue]
    }
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? SummaryCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib(nibName: SummaryCell.identifire, bundle: Rechka.shared.bundle), forCellReuseIdentifier: SummaryCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SummaryCell.identifire, for: indexPath) as? SummaryCell else { return .init() }
        return cell
    }
}

class SummaryCell : UITableViewCell {
    
    private var onMore: Command<Void>?
    
    private var gradient: CAGradientLayer?
    
    @IBOutlet private weak var mainTextLabel: UILabel!
    
    @IBOutlet private weak var moreButton: UIButton!
    
    @IBOutlet private weak var gradientView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let base = Appearance.colors[.base] ?? UIColor.clear
        guard let gradient = gradient else { return }
        gradient.colors = [base.withAlphaComponent(0).cgColor, base.cgColor]
        gradient.frame = .init(x: 0, y: self.gradientView.frame.height / 2, width: UIScreen.main.bounds.width, height: self.gradientView.frame.height)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    @IBAction func handleMore(_ sender: Any) {
        onMore?.perform(with: ())
    }
    
    public func configure(with data: _Summary) {
        mainTextLabel.attributedText = data.text
        self.onMore = data.onMore
        addGradient()
        guard let gradient = gradient else { return }
        gradientView.isHidden = data.onMore == nil
    
        var gradientFrame = gradient.frame
        gradientFrame.size.height = data.height
        self.gradient!.frame = gradientFrame
        
        let base = Appearance.colors[.base] ?? UIColor.clear
        gradient.colors = [base.withAlphaComponent(0).cgColor, base.cgColor]
        gradient.frame = .init(x: 0, y: self.gradientView.frame.height / 2, width: UIScreen.main.bounds.width, height: self.gradientView.frame.height)
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    private func addGradient() {
        self.gradient = CAGradientLayer()
        guard let gradient = gradient else {
            return
        }
        gradient.frame = .init(x: 0, y: self.gradientView.frame.height / 2, width: UIScreen.main.bounds.width, height: self.gradientView.frame.height)
        let base = Appearance.colors[.base] ?? UIColor.clear
        
        gradient.colors = [base.cgColor, base.cgColor]
        gradient.locations = [0, 0.6]
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.startPoint = CGPoint(x: 0, y: 0)
        self.gradientView.layer.insertSublayer(gradient, at: 0)
    }
}
