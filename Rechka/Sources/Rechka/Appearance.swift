//
//  Appearance.swift
//  
//
//  Created by Слава Платонов on 07.03.2022.
//

import UIKit

class TerminalBubbleView : UIView {
        
    var onSelect : (() -> Void)?
    
    let bubbleView : UIView = {
        let view = UIView()
        view.alpha = 0.9
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.frame = CGRect(x: 0, y: 0, width: 230, height: 60)
        return view
    }()
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.label
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.customFont(forTextStyle: .body)
        label.frame = CGRect(x: 60, y: 0, width: 130, height: 60)
        return label
    }()
    
    let shipImageView : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 16, y: 17.5, width: 25, height: 25))
        imageView.tintColor = .label
        imageView.image = UIImage(named: "ship")!
        return imageView
    }()
    
    let chevronImageView : UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 203, y: 22.5, width: 10, height: 15))
        imageView.tintColor = .label
        imageView.image = UIImage(systemName: "chevron.right")!
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        addSubview(bubbleView)
        bubbleView.addSubview(titleLabel)
        bubbleView.addSubview(shipImageView)
        bubbleView.addSubview(chevronImageView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        shipImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            bubbleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            bubbleView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            
            titleLabel.heightAnchor.constraint(equalToConstant: 60),
            titleLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 60),
            titleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 0),
            
            shipImageView.widthAnchor.constraint(equalToConstant: 25),
            shipImageView.heightAnchor.constraint(equalToConstant: 25),
            shipImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 17.5),
            shipImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 17.5),
            
            chevronImageView.widthAnchor.constraint(equalToConstant: 10),
            chevronImageView.heightAnchor.constraint(equalToConstant: 25),
            chevronImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 17.5),
            chevronImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16)
        ])
    }
}

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
