//
//  BlurRefundController.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit

final class BlurRefundController : UIViewController {
    
    
    public var orderID: Int?
    
    public var ticket: RiverOperationTicket? {
        didSet {
            
        }
    }
    
    
    
    private let nestedView = BlurRefundView.loadFromNib()
    
    override func loadView() {
        self.view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nestedView.viewState = .loading(.init(title: "Считаем сумму возврата", descr: "Немного подождите"))
    }
}

extension BlurRefundController {
    
//    private func makeState() async -> BlurRefundView.ViewState {
//        
//        
//        
//    }
    
}
