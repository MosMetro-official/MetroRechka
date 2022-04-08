//
//  TripsDateHeader.swift
//  
//
//  Created by guseyn on 30.03.2022.
//

import UIKit
import CoreTableView


protocol _TripsDateHeader: HeaderData {
    var title: String { get }
}

extension _TripsDateHeader {
    
    func header(for tableView: UITableView, section: Int) -> UIView? {
           tableView.register(TripsDateHeader.nib, forHeaderFooterViewReuseIdentifier: TripsDateHeader.identifire)
           guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TripsDateHeader.identifire) as? TripsDateHeader else { return nil }
           header.configure(with: self)
           return header
       }
    
    func hashValues() -> [Int] {
        return [title.hashValue]
    }
    
    var height: CGFloat {
        return 40
    }
}

class TripsDateHeader: UITableViewHeaderFooterView {

    @IBOutlet private weak var mainTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainTitleLabel.font = Appearance.customFonts[.headline]
        self.mainTitleLabel.textColor = Appearance.colors[.textPrimary]
    }
    
    func configure(with data: _TripsDateHeader) {
        self.mainTitleLabel.text  = data.title
    }
    
    
}
