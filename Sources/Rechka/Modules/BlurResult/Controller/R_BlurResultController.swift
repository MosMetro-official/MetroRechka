//
//  R_BlurResultController.swift
//  
//
//  Created by polykuzin on 28/03/2022.
//

import UIKit
import CoreTableView

internal final class R_BlurResultController : UIViewController {
    
    var model: R_BlurResultModel? {
        didSet {
            makeState()
        }
    }
    
    private let nestedView = R_BlurResultView.loadFromNib()
    
    override func loadView() {
        self.view = nestedView
    }
    
    private func makeState() {
        guard let model = model else { return }
        let onClose = Command { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        let onRetry = Command { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        switch model {
        case .success(let data):
            self.nestedView.viewState = .init(title: data.title,
                                              subtitle: data.subtitle,
                                              image: UIImage(named: "checkmark", in: Rechka.shared.bundle, compatibleWith: nil) ?? UIImage(),
                                              onClose: onClose,
                                              onRetry: nil)
        case .failure(let data):
            self.nestedView.viewState = .init(title: data.title,
                                              subtitle: data.subtitle,
                                              image: UIImage(named: "result_error", in: Rechka.shared.bundle, compatibleWith: nil) ?? UIImage(),
                                              onClose: onClose,
                                              onRetry: onRetry)
        }
    }
}
