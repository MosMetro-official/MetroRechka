//
//  File.swift
//  
//
//  Created by Слава Платонов on 10.03.2022.
//

import UIKit

extension UIFont {
    /// Method for register fonts from package
    open class func registerFont(bundle: Bundle, fontName: String, fontExtension: String) -> Bool {
        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension) else {
            fatalError("Couldn't find font \(fontName)")
        }
        guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
            fatalError("Couldn't load data from the font \(fontName)")
        }
        guard let font = CGFont(fontDataProvider) else {
            fatalError("Couldn't create font from data")
        }
        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterGraphicsFont(font, &error)
        guard success else {
            print("Error registering font: maybe it was already registered.")
            return false
        }
        return true
    }
    
    /// Method to set custom fonts
    open class func customFont(forTextStyle style: FontTextStyle) -> UIFont {
        let customFont = Appearance.customFonts[style] ?? UIFont.systemFont(ofSize: 17, weight: .regular)
        return customFont
    }
}
