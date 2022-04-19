//
//  R_BlurLoadingController.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit

internal final class R_BlurLoadingController : UIViewController {
    
    public var onClose : (() -> Void)?
    
    public init(with data: _BlurLoading) {
        super.init(nibName: nil, bundle: nil)
        self.nestedView.configure(with: data)
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let nestedView = R_BlurLoadingView.loadFromNib()
    
    override func loadView() {
        self.view = nestedView
    }
}
