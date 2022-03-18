//
//  BottomSettingsView.swift
//  
//
//  Created by Слава Платонов on 11.03.2022.
//

import UIKit

class BottomSettingsView: UIView {
    
    public var onPersonsMenu : ((Int) -> Void)?
    public var onCategoriesMenu : (() -> Void)?
    public var onTerminalsButton : (() -> Void)?
    
    public var swowDatesAlert : (() -> Void)?
    public var swowPersonsAlert : (() -> Void)?
    public var swowCategoriesAlert : (() -> Void)?
    
    private let datesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🗓 Даты", for: .normal)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 16)
        button.tintColor = .white
        button.backgroundColor = Appearance.colors[.settingsButtonColor]
        return button
    }()
    
    private let personsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🙋‍♂️ 1", for: .normal)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 16)
        button.tintColor = .white
        button.backgroundColor = Appearance.colors[.settingsButtonColor]
        return button
    }()
    
    private let terminalsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🛥️ Причал", for: .normal)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 16)
        button.tintColor = .white
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = Appearance.colors[.settingsButtonColor]
        return button
    }()
    
    private let categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("↓ Категория", for: .normal)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 16)
        button.tintColor = .white
        button.backgroundColor = Appearance.colors[.settingsButtonColor]
        return button
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🎚 Фильтры", for: .normal)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 16)
        button.tintColor = .white
        button.backgroundColor = Appearance.colors[.settingsButtonColor]
        return button
    }()
    
    private lazy var firstLinebuttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [datesButton, personsButton, terminalsButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private lazy var secondLineButtonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [categoryButton, filterButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private var bgBlurView : UIVisualEffectView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bgBlurView = UIVisualEffectView(frame: frame)
        let effect = UIBlurEffect(style: .systemChromeMaterial)
        bgBlurView.effect = effect
        setupActions()
        setupConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCategoriesMenu() -> [UIAction] {
        let holiday = UIAction(
            title: "🌶 23 февраля"
        ) { [weak self] _ in
            guard let self = self else { return }
            self.onCategoriesMenu?()
        }
        return [
            holiday
        ]
    }
    
    private func setupPersonsMenu() -> [UIAction] {
        let party = UIAction(
            title: "Пятеро",
            image: UIImage(named: "lonely", in: .module, compatibleWith: nil) ?? UIImage()
        ) { [weak self]_ in
            guard let self = self else { return }
            self.onPersonsMenu?(5)
        }
        let bigFamily = UIAction(
            title: "Четверо",
            image: UIImage(named: "big_family", in: .module, compatibleWith: nil) ?? UIImage()
        ) { [weak self]_ in
            guard let self = self else { return }
            self.onPersonsMenu?(4)
        }
        let smallFamily = UIAction(
            title: "Трое",
            image: UIImage(named: "small_family", in: .module, compatibleWith: nil) ?? UIImage()
        ) { [weak self]_ in
            guard let self = self else { return }
            self.onPersonsMenu?(3)
        }
        let couple = UIAction(
            title: "Пара",
            image: UIImage(named: "couple", in: .module, compatibleWith: nil) ?? UIImage()
        ) { [weak self]_ in
            guard let self = self else { return }
            self.onPersonsMenu?(2)
        }
        let lonely = UIAction(
            title: "Для одного",
            image: UIImage(named: "lonely", in: .module, compatibleWith: nil) ?? UIImage()
        ) { [weak self]_ in
            guard let self = self else { return }
            self.onPersonsMenu?(1)
        }
        return [
            lonely,
            couple,
            smallFamily,
            bigFamily,
            party
        ]
    }
    
    private func setupActions() {
        filterButton.alpha = 0.3
        filterButton.isEnabled = false
        categoryButton.alpha = 0.3
        categoryButton.isEnabled = false
        terminalsButton.addTarget(self, action: #selector(openTerminals), for: .touchUpInside)
        if #available(iOS 14, *) {
            personsButton.showsMenuAsPrimaryAction = true
            personsButton.menu = UIMenu(title: "", children: setupPersonsMenu())
            categoryButton.showsMenuAsPrimaryAction = true
            categoryButton.menu = UIMenu(title: "", children: setupCategoriesMenu())
        } else {
            personsButton.addTarget(self, action: #selector(onPersonsSelect), for: .touchUpInside)
            categoryButton.addTarget(self, action: #selector(onCategoriesSelect), for: .touchUpInside)
        }
        datesButton.addTarget(self, action: #selector(onDatesTap), for: .touchUpInside)
    }
    
    @objc
    private func onDatesTap() {
        self.swowDatesAlert?()
    }
    
    @objc
    private func onPersonsSelect() {
        self.swowPersonsAlert?()
    }
    
    @objc
    private func onCategoriesSelect() {
        self.swowCategoriesAlert?()
    }
    
    @objc
    private func openTerminals() {
        onTerminalsButton?()
    }
    
    private func setupConstrains() {
        addSubview(bgBlurView)
        bgBlurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(firstLinebuttonsStackView)
        addSubview(secondLineButtonsStackView)
        NSLayoutConstraint.activate([
            bgBlurView.topAnchor.constraint(equalTo: topAnchor),
            bgBlurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgBlurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bgBlurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            personsButton.widthAnchor.constraint(equalToConstant: 81),
            firstLinebuttonsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            firstLinebuttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            firstLinebuttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            firstLinebuttonsStackView.heightAnchor.constraint(equalToConstant: 40),
                
            secondLineButtonsStackView.topAnchor.constraint(equalTo: firstLinebuttonsStackView.bottomAnchor, constant: 8),
            secondLineButtonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            secondLineButtonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            secondLineButtonsStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
