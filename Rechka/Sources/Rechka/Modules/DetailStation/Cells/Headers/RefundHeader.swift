//
//  RefundHeader.swift
//  
//
//  Created by Слава Платонов on 16.03.2022.
//

import UIKit
import CoreTableView

protocol _RefundHeader: HeaderData {
    var isExpanded: Bool { get set }
    var onSelect: () -> () { get set }
}

extension _RefundHeader {
    func header(for tableView: UITableView, section: Int) -> UIView? {
        tableView.register(RefundHeader.nib, forHeaderFooterViewReuseIdentifier: RefundHeader.identifire)
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: RefundHeader.identifire) as? RefundHeader else { return nil }
        header.configure(with: self)
        return header
    }
}

class RefundHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var refundLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    public var onExpandTap: (()->())?
    
    var isExpanded: Bool! {
        didSet {
            if isExpanded {
                arrowImage.image = UIImage(systemName: "arrow.down")
            } else {
                arrowImage.image = UIImage(systemName: "arrow.up")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        refundLabel.font = UIFont(name: "MoscowSans-Bold", size: 20)
        backView.layer.cornerRadius = 10
        setupGesture()
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hadlerTap))
        tapGesture.numberOfTapsRequired = 1
        backView.addGestureRecognizer(tapGesture)
    }
    
    private func expandAnimation() {
        UIView.transition(with: arrowImage, duration: 0.5, options: .transitionCrossDissolve) {
            if self.isExpanded {
                self.arrowImage.image = UIImage(systemName: "arrow.down")
            } else {
                self.arrowImage.image = UIImage(systemName: "arrow.up")
            }
        }
    }
    
    @objc private func hadlerTap() {
        isExpanded.toggle()
        expandAnimation()
        onExpandTap?()
    }
    
    public func configure(with data: _RefundHeader) {
        isExpanded = data.isExpanded
        onExpandTap = data.onSelect
    }
    
}
