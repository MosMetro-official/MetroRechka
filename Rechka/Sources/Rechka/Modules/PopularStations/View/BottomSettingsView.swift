//
//  BottomSettingsView.swift
//  
//
//  Created by Слава Платонов on 11.03.2022.
//

import UIKit

class BottomSettingsView: UIView {
    
    public var onDatesMenu : (() -> Void)?
    public var onPersonsMenu : ((Int) -> Void)?
    public var onTerminalsButton : (() -> Void)?
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActions()
        setupConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDatesMenu() -> [UIAction] {
        // TODO: откуда-то их брать наверное?/
        let holiday = UIAction(
            title: "🌶 23 февраля"
        ) { [weak self] _ in
            guard let self = self else { return }
            self.onDatesMenu?()
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
            datesButton.showsMenuAsPrimaryAction = true
            datesButton.menu = UIMenu(title: "", children: setupDatesMenu())
            personsButton.showsMenuAsPrimaryAction = true
            personsButton.menu = UIMenu(title: "", children: setupPersonsMenu())
        } else {
            
        }
    }
    
    @objc
    private func openTerminals() {
        onTerminalsButton?()
    }
    
    private func setupConstrains() {
        addSubview(firstLinebuttonsStackView)
        addSubview(secondLineButtonsStackView)
        NSLayoutConstraint.activate(
            [
                personsButton.widthAnchor.constraint(equalToConstant: 81),
                firstLinebuttonsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
                firstLinebuttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                firstLinebuttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                firstLinebuttonsStackView.heightAnchor.constraint(equalToConstant: 40),
                
                secondLineButtonsStackView.topAnchor.constraint(equalTo: firstLinebuttonsStackView.bottomAnchor, constant: 8),
                secondLineButtonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                secondLineButtonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                secondLineButtonsStackView.heightAnchor.constraint(equalToConstant: 40)
            ]
        )
    }
}
