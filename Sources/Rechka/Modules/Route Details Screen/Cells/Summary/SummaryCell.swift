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
        tableView.register(UINib(nibName: SummaryCell.identifire, bundle: .module), forCellReuseIdentifier: SummaryCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SummaryCell.identifire, for: indexPath) as? SummaryCell else { return .init() }
        return cell
    }
}

class SummaryCell: UITableViewCell {

    @IBOutlet weak var mainTextLabel: UILabel!
    private var gradient: CAGradientLayer?
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    
    private var onMore: Command<Void>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
    
    
    @IBAction func handleMore(_ sender: Any) {
        onMore?.perform(with: ())
    }
    
    public func configure(with data: _Summary) {
        mainTextLabel.attributedText = data.text
        self.onMore = data.onMore
        guard let gradient = gradient else { return }
        gradientView.isHidden = data.onMore == nil
    
        var gradientFrame = gradient.frame
        gradientFrame.size.height = data.height - 24
        self.gradient!.frame = gradientFrame
    }
    
    private func addGradient() {
        self.gradient = CAGradientLayer()
        guard let gradient = gradient else {
            return
        }
        gradient.frame =  CGRect(origin: CGPoint(x: 0, y: 0), size: .init(width: UIScreen.main.bounds.width - 40, height: self.gradientView.frame.height))
        let base = Appearance.colors[.base] ?? UIColor.clear
        
        gradient.colors = [base.withAlphaComponent(0.2).cgColor, base.cgColor]
        gradient.locations = [0.2,0.8]
//        gradient.startPoint = CGPoint(x: 0, y: 1)
//        gradient.endPoint = CGPoint(x: 1, y: 1)
        self.gradientView.layer.insertSublayer(gradient, at: 0)
    }
    
}
