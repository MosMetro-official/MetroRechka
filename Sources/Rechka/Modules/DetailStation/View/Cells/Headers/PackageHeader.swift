//
//  PackageHeader.swift
//  
//
//  Created by Слава Платонов on 16.03.2022.
//

import UIKit
import CoreTableView

protocol _PackageHeader: HeaderData {
    var isExpanded: Bool { get }
    var onExpandTap: () -> () { get }
}

extension _PackageHeader {
    public func hashValues() -> [Int] {
        return [isExpanded.hashValue]
    }
    
    func header(for tableView: UITableView, section: Int) -> UIView? {
        tableView.register(PackageHeader.nib, forHeaderFooterViewReuseIdentifier: PackageHeader.identifire)
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PackageHeader.identifire) as? PackageHeader else { return nil }
        header.configure(with: self)
        return header
    }
}

class PackageHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var packageLabel: UILabel!
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
        packageLabel.font = UIFont(name: "MoscowSans-Bold", size: 20)
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
    
    public func configure(with data: _PackageHeader) {
        isExpanded = data.isExpanded
        onExpandTap = data.onExpandTap
    }

}
