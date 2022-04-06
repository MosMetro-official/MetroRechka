//
//  R_CancelBookingController.swift
//  
//
//  Created by polykuzin on 24/03/2022.
//

import UIKit

internal final class R_CancelBookingController : UIViewController {
    
    private let nestedView = R_CancelBookingView.loadFromNib()
    
    override func loadView() {
        self.view = nestedView
        nestedView.onCloseTap = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
