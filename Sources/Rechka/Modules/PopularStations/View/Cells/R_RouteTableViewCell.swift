//
//  R_RouteTableViewCell.swift
//  
//
//  Created by Гусейн on 20.04.2022.
//

import UIKit
import CoreTableView
import SDWebImage

protocol _R_RouteTableViewCell: CellData {
    var title: String { get }
    var time: String { get }
    var station: String { get }
    var priceButtonTitle: String { get }
    var imageURL: String? { get }
}

extension _R_RouteTableViewCell {
    
    func hashValues() -> [Int] {
        return [title.hashValue,time.hashValue,station.hashValue]
    }
    
    var height: CGFloat {
        return (UIScreen.main.bounds.width - 40) * 0.65
    }
    
    
    func prepare(cell: UITableViewCell, for tableView: UITableView, indexPath: IndexPath) {
        guard let cell = cell as? R_RouteTableViewCell else { return }
        cell.configure(with: self)
    }
    
    func cell(for tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        tableView.register(R_RouteTableViewCell.nib, forCellReuseIdentifier: R_RouteTableViewCell.identifire)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R_RouteTableViewCell.identifire, for: indexPath) as? R_RouteTableViewCell else { return .init() }
        return cell
    }
    
    
}

class R_RouteTableViewCell: UITableViewCell {
    
    @IBOutlet var mainTitleLabel: UILabel!
    @IBOutlet var leftImageView: UIImageView!
    @IBOutlet var priceButton: UIButton!
    @IBOutlet var stationLabel: UILabel!
    @IBOutlet var cardView: UIView!
    @IBOutlet var timeLabel: UILabel!
    
    private var buttonGradient: CAGradientLayer?
    
    
    private var imageURL: String? {
        didSet {
            if let imageURL = imageURL {
                guard let photoURL = URL(string: imageURL) else { return }
                leftImageView.sd_setImage(with: photoURL, completed: nil)
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [cardView,leftImageView].forEach {
            $0?.roundCorners(.all, radius: 16)
        }
        
        priceButton.roundCorners(.all, radius: 12)
        addHorizontalGradientLayer()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let buttonGradient = buttonGradient else { return }
        let screenBounds = UIScreen.main.bounds.width - 40
        let buttonWidth = (screenBounds - (screenBounds * 0.3)) - 7 - 24
        buttonGradient.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: 32)
    }

    private func addHorizontalGradientLayer() {
        let gradientLayer = CAGradientLayer()
        let screenBounds = UIScreen.main.bounds.width - 40
        let buttonWidth = (screenBounds - (screenBounds * 0.3)) - 7 - 24
        gradientLayer.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: 32)
        gradientLayer.colors = [#colorLiteral(red: 0, green: 0.4075400233, blue: 0.7539479136, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0.7945067286, blue: 0.8337443471, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        self.buttonGradient = gradientLayer
        self.priceButton.layer.addSublayer(self.buttonGradient!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with data: _R_RouteTableViewCell) {
        self.imageURL = data.imageURL
        self.mainTitleLabel.text = data.title
        self.priceButton.setTitle(data.priceButtonTitle, for: .normal)
        self.stationLabel.text = data.station
        self.timeLabel.text = data.time
    }
    
}
