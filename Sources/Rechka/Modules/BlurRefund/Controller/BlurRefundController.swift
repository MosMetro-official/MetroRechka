//
//  BlurRefundController.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit

final class BlurRefundController : UIViewController {
    
    public init(with data: _BlurRefund) {
        super.init(nibName: nil, bundle: nil)
        self.nestedView.configure(with: data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let nestedView = BlurRefundView.loadFromNib()
    
    override func loadView() {
        self.view = nestedView
    }
}
