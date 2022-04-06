//
//  R_BlurRefundController.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit

internal final class R_BlurRefundController : UIViewController {
    
    public init(with data: _BlurRefund) {
        super.init(nibName: nil, bundle: nil)
        self.nestedView.configure(with: data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let nestedView = R_BlurRefundView.loadFromNib()
    
    override func loadView() {
        self.view = nestedView
    }
}
