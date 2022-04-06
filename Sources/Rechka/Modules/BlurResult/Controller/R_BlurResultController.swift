//
//  R_BlurResultController.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit

internal final class R_BlurResultController : UIViewController {
    
    /// честно говоря, не знаю зачем она здесь
    public var onClose : (() -> Void)?
    
    public init(with data: _BlurResult) {
        super.init(nibName: nil, bundle: nil)
        self.nestedView.configure(with: data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let nestedView = R_BlurResultView.loadFromNib()
    
    override func loadView() {
        self.view = nestedView
    }
}
