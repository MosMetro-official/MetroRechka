//
//  BlurLoadingController.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit

final class BlurLoadingController : UIViewController {
    
    /// честно говоря, не знаю зачем она здесь
    public var onClose : (() -> Void)?
    
    public init(with data: _BlurLoading) {
        super.init(nibName: nil, bundle: nil)
        self.nestedView.configure(with: data)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let nestedView = BlurLoadingView.loadFromNib()
    
    override func loadView() {
        self.view = nestedView
    }
}
