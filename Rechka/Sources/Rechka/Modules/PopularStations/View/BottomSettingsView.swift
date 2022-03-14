//
//  BottomSettingsView.swift
//  
//
//  Created by Слава Платонов on 11.03.2022.
//

import UIKit

class BottomSettingsView: UIView {
    
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
    
    private let stationsButton: UIButton = {
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
        let stackView = UIStackView(arrangedSubviews: [datesButton, personsButton, stationsButton])
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
        setupConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstrains() {
        addSubview(firstLinebuttonsStackView)
        addSubview(secondLineButtonsStackView)
        NSLayoutConstraint.activate(
            [
                personsButton.widthAnchor.constraint(equalToConstant: 81),
                firstLinebuttonsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
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
