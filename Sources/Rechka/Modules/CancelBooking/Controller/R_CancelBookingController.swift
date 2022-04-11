//
//  R_CancelBookingController.swift
//  
//
//  Created by polykuzin on 24/03/2022.
//

import UIKit
import CoreTableView

internal final class R_CancelBookingController : UIViewController {
    
    private let nestedView = R_CancelBookingView.loadFromNib()
    
    var onClose: Command<Void>?
    
    override func loadView() {
        self.view = nestedView
        nestedView.onCloseTap = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dismiss(animated: true) { [weak self] in
                    self?.onClose?.perform(with: ())
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
