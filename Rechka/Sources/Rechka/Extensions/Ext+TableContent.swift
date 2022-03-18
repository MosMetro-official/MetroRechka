//
//  Ext+TableContent.swift
//  
//
//  Created by Слава Платонов on 09.03.2022.
//

import UIKit

extension UITableViewCell {
    
    static var nib  : UINib {
        return UINib(nibName: identifire, bundle: .module)
    }
    
    static var identifire : String {
        return String(describing: self)
    }
}

extension UICollectionViewCell {
    static var nib  : UINib {
        return UINib(nibName: identifire, bundle: .module)
    }
    
    static var identifire : String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView {
    static var nib  : UINib {
        return UINib(nibName: identifire, bundle: .module)
    }
    
    static var identifire : String {
        return String(describing: self)
    }
}
