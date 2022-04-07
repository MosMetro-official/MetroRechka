//
//  Ext+UIViewController.swift
//  
//
//  Created by Слава Платонов on 24.03.2022.
//

import UIKit

extension UIViewController {
    func setupRiverBackButton() {
        navigationItem.hidesBackButton = true
        let backItem = UIBarButtonItem(
            image: UIImage(named: "chevronLeft", in: .module, compatibleWith: nil)!,
            style: .plain,
            target: self,
            action: #selector(riverBackButtonPressed)
        )
        navigationItem.leftBarButtonItem = backItem
    }
    
    @objc
    private func riverBackButtonPressed() {
        guard let navigation = self.navigationController else { return }
        navigation.popViewController(animated: true)
    }
}
