//
//  Ext+UIViewController.swift
//  
//
//  Created by Слава Платонов on 24.03.2022.
//

import UIKit

extension UIViewController {
    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyb)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyb() {
        view.endEditing(true)
    }
}
