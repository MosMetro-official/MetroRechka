//
//  BlurLoadingView.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit

protocol _BlurLoading {
    var title : String { get }
    var descr : String { get }
}

final class BlurLoadingView : UIView {
    
    public func configure(with data: _BlurLoading) {
        title.text = data.title
        descr.text = data.descr
    }
    
    @IBOutlet private weak var title : UILabel!
    
    @IBOutlet private weak var descr : UILabel!
    
    @IBOutlet private weak var spinner : UIActivityIndicatorView!
}
