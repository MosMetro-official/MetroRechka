//
//  R_UnauthorizedController.swift
//  
//
//  Created by guseyn on 01.04.2022.
//

import UIKit
import CoreTableView
import SafariServices

internal final class R_UnauthorizedController : UIViewController {
    
    public var onLogin: Command<Void>?
    
    private var nestedView = R_UnauthorizedView.loadFromNib()
        
    override func loadView() {
        super.loadView()
        self.view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let onMore = Command { [weak self] in
            guard let url = URL(string: "https://mosmetro.ru/app/") else { return }
            let safariVC = SFSafariViewController(url: url)
            self?.present(safariVC, animated: true, completion: nil)
        }
        let onClose = Command { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        let onLogin = Command { [weak self] in
            self?.dismiss(animated: true, completion: { [weak self] in
                self?.onLogin?.perform(with: ())
            })
        }
        self.nestedView.viewState = .init(onMore: onMore, onClose: onClose, onLogin: onLogin)
    }
}
