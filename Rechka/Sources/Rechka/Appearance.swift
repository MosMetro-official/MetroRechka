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
    case emptyTicketsLayer
    case settingsPanel
    case priceLayer
    case settingsButtonColor
}

protocol _Appearance: AnyObject {
    static var customFonts: [UIFont.TextStyle: UIFont] { get }
    static var colors: [Colors: UIColor] { get }
}

public class Appearance: _Appearance {
    
    static func makeRechkaTerminalImage(from terminal: _RechkaTerminal) -> UIImage {
        let bubble = TerminalBubbleView(frame: CGRect(x: 0, y: 0, width: 230, height: 100))
        bubble.titleLabel.text = terminal.title
        bubble.onSelect = {
            terminal.onSelect()
        }
        bubble.layoutSubviews()
        return bubble.asImage()
    }
    
    static var customFonts: [UIFont.TextStyle: UIFont] = [
        .largeTitle: UIFont(name: "MoscowSans-Regular", size: 34) ?? UIFont(),
        .title1: UIFont(name: "MoscowSans-Bold", size: 22) ?? UIFont(),
        .title2: UIFont(name: "MoscowSans-Regular", size: 22) ?? UIFont(),
        .title3: UIFont(name: "MoscowSans-Bold", size: 16) ?? UIFont(),
        .headline: UIFont(name: "MoscowSans-Regular", size: 14) ?? UIFont(),
        .body: UIFont(name: "MoscowSans-Regular", size: 17) ?? UIFont(),
        .callout: UIFont(name: "MoscowSans-Regular", size: 16) ?? UIFont(),
        .subheadline: UIFont(name: "MoscowSans-Regular", size: 15) ?? UIFont(),
        .footnote: UIFont(name: "MoscowSans-Regular", size: 13) ?? UIFont(),
        .caption1: UIFont(name: "MoscowSans-Regular", size: 12) ?? UIFont(),
        .caption2: UIFont(name: "MoscowSans-Regular", size: 11) ?? UIFont()
    ]
    
    static var colors: [Colors : UIColor] = [
        .base: UIColor(named: Colors.base.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
        .content: UIColor(named: Colors.content.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
        .emptyTicketsLayer: UIColor(named: Colors.emptyTicketsLayer.rawValue) ?? UIColor(),
        .priceLayer: UIColor(named: Colors.priceLayer.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
        .settingsButtonColor: UIColor(named: Colors.settingsButtonColor.rawValue, in: .module, compatibleWith: nil) ?? UIColor(),
        .settingsPanel: UIColor(named: Colors.settingsPanel.rawValue, in: .module, compatibleWith: nil) ?? UIColor()
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
