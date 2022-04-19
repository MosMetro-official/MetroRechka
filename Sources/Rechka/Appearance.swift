//
//  Appearance.swift
//  
//
//  Created by Слава Платонов on 07.03.2022.
//

import UIKit

public enum Colors: String {
    case base
    case content
    case priceLayer
    case textPrimary
    case textInverted
    case textSecondary
    case settingsPanel
    case buttonSecondary
    case emptyTicketsLayer
    case settingsButtonColor
}

public enum FontTextStyle: String {
    case largeTitle = "largeTitle"
    case title1 = "title1"
    case title2 = "title2"
    case headline = "headline"
    case body = "body"
    case subhead = "subhead"
    case button1 = "button1"
    case button2 = "button2"
    case button3 = "button3"
    case footnote = "footnote"
    case caption1 = "caption1"
    case caption2 = "caption2"
}

protocol _Appearance: AnyObject {
    static var customFonts: [FontTextStyle: UIFont] { get }
    static var colors: [Colors: UIColor] { get }
}

public final class Appearance: _Appearance {
    
    static func makeRechkaTerminalImage(from terminal: R_Station) -> UIImage {
        let bubble = TerminalBubbleView(frame: CGRect(x: 0, y: 0, width: 230, height: 100))
        bubble.titleLabel.text = terminal.name
        bubble.onSelect = {
            terminal.onSelect()
        }
        bubble.layoutSubviews()
        return bubble.asImage()
    }
    
    public static var customFonts: [FontTextStyle: UIFont] = [
        .largeTitle: UIFont(name: "MoscowSans-Bold", size: 30) ?? UIFont.systemFont(ofSize: 30, weight: .bold),
        .title1: UIFont(name: "MoscowSans-Bold", size: 26) ?? UIFont.systemFont(ofSize: 26, weight: .bold),
        .title2: UIFont(name: "MoscowSans-Medium", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .medium),
        .headline: UIFont(name: "MoscowSans-Medium", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .medium),
        .body: UIFont(name: "MoscowSans-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .regular),
        .subhead: UIFont(name: "MoscowSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .regular),
        .button1: UIFont(name: "MoscowSans-Medium", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .medium),
        .button2: UIFont(name: "MoscowSans-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium),
        .button3: UIFont(name: "MoscowSans-Medium", size: 10) ?? UIFont.systemFont(ofSize: 10, weight: .medium),
        .footnote: UIFont(name: "MoscowSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .regular),
        .caption1: UIFont(name: "MoscowSans-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .regular),
        .caption2: UIFont(name: "MoscowSans-Regular", size: 11) ?? UIFont.systemFont(ofSize: 11, weight: .regular),
    ]
    
    public static var colors: [Colors : UIColor] = [
        .base: UIColor(named: Colors.base.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
        .content: UIColor(named: Colors.content.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
        .priceLayer: UIColor(named: Colors.priceLayer.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
        .settingsPanel: UIColor(named: Colors.settingsPanel.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
        .textPrimary: UIColor(named: Colors.textPrimary.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
        .textInverted: UIColor(named: Colors.textInverted.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
        .textSecondary: UIColor(named: Colors.textSecondary.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
        .buttonSecondary: UIColor(named: Colors.buttonSecondary.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
        .emptyTicketsLayer: UIColor(named: Colors.emptyTicketsLayer.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
        .settingsButtonColor: UIColor(named: Colors.settingsButtonColor.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
    ]
}

extension UIColor {
    
    class func custom(for color: Colors) -> UIColor {
        return Appearance.colors[color] ?? UIColor()
    }
    
    open class var settingsPanel: UIColor {
        return UIColor { (traits) -> UIColor in
            return traits.userInterfaceStyle == .light ? lightSettingPanel : darkSettingsPanel
        }
    }
    
    class var darkSettingsPanel: UIColor {
        return UIColor.custom(for: .settingsPanel)
    }
    
    class var lightSettingPanel: UIColor {
        return UIColor.custom(for: .settingsPanel)
    }
}
