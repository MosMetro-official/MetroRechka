//
//  R_BookingWithPersonView.swift
//  
//
//  Created by Слава Платонов on 21.03.2022.
//

import UIKit
import CoreTableView

internal final class R_BookingWithPersonView: UIView {
    
    struct ViewState {
        
        var state: [State]
        var dataState: DataState
        
        enum DataState {
            case addPersonData
            case addedPersonData([State])
        }
        
        struct PassengerHeader: _PassengerHeaderCell {
            let onAdd: () -> ()
            let height: CGFloat
        }
        
        struct Passenger: _Passenger {
            let name: String
            let tariff: String
            let height: CGFloat
        }
        
        struct TariffHeader: _TariffHeaderCell {
            let height: CGFloat
        }
        
        struct Tariff: _Tariff {
            let tariffs: String
            let price: String
            let height: CGFloat
        }
        
        struct Commission: _Commission {
            let commission: String
            let price: String
            let height: CGFloat
        }
        
        static let initial = R_BookingWithPersonView.ViewState(state: [], dataState: .addPersonData)
    }
    
    public var state: R_BookingWithPersonView.ViewState = .initial {
        didSet {
            updateView()
        }
    }
    
    public var showPersonAlert: (() -> Void)?
    public var showPersonDataEntry: (() -> Void)?
    public var showUserFromCache: ((R_User) -> Void)?
    
    private let tableView: BaseTableView = {
        let table = BaseTableView(frame: .zero, style: .insetGrouped)
        table.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        table.sectionFooterHeight = .leastNormalMagnitude
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorColor = .clear
        table.clipsToBounds = true
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.isHidden = true
        return table
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Appearance.colors[.base]
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "MoscowSans-Bold", size: 22)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private let userProfileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user_profile", in: .module, with: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "MoscowSans-Bold", size: 22)
        label.text = "Персональные данные"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "MoscowSans-Regular", size: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "На данном рейсе необходимо указать персональные данные пассажиров"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.tintColor = .black
        button.backgroundColor = .white
        button.setTitle("Добавить", for: .normal)
        button.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .custom(for: .settingsPanel)
        view.layer.isOpaque = false
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()
    
    private let bookButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.custom(for: .buttonSecondary)
        button.tintColor = UIColor.custom(for: .textPrimary)
        button.setTitleColor(UIColor.custom(for: .textInverted), for: .normal)
        button.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 10
        button.setTitle("Забронировать", for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Appearance.colors[.base]
        setupConstrains()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPersonsMenu() -> [UIAction] {
        var actions: [UIAction] = []
        guard let users = SomeCache.shared.cache["user"] else { return [] }
        users.forEach { user in
            let action = UIAction(
                title: "\(user.surname ?? "") \(user.name?.first ?? Character("")). \(user.middleName?.first ?? Character("")).",
                image: UIImage(systemName: "person")) { _ in
                    self.showUserFromCache?(user)
                }
            actions.append(action)
        }
        let addAction = UIAction(title: "Новый пасажир", image: UIImage(systemName: "plus")) { _ in
            self.pushPersonDataEntry()
        }
        actions.append(addAction)
        return actions
    }
    
    private func setupAction() {
        guard let users = SomeCache.shared.cache["user"] else { return }
        if !users.isEmpty {
            if #available(iOS 14, *) {
                addButton.showsMenuAsPrimaryAction = true
                addButton.menu = UIMenu(title: "Persons", children: setupPersonsMenu())
            } else {
                addButton.addTarget(self, action: #selector(onPersonsSelect), for: .touchUpInside)
            }
        } else {
            addButton.addTarget(self, action: #selector(pushPersonDataEntry), for: .touchUpInside)
        }

    }
    
    @objc private func onPersonsSelect() {
        showPersonAlert?()
    }
    
    @objc private func pushPersonDataEntry() {
        print("pushing new screen")
        showPersonDataEntry?()
    }
    
    private func updateView() {
        switch state.dataState {
        case .addPersonData:
            tableView.isHidden = true
            layoutSubviews()
        case .addedPersonData(let state):
            containerView.isHidden = true
            tableView.isHidden = false
            buttonView.isHidden = false
            tableView.viewStateInput = state
            layoutSubviews()
        }
    }

    public func configureTitle(with model: FakeModel) {
        titleLabel.text = model.title
    }
    
    public func onReload() {
        setupAction()
    }
}

extension R_BookingWithPersonView {
    private func setupConstrains() {
        addSubview(containerView)
        addSubview(tableView)
        addSubview(titleLabel)
        addSubview(buttonView)
        buttonView.addSubview(bookButton)
        [userProfileImage, summaryLabel, descriptionLabel, addButton].forEach { view in
            containerView.addSubview(view)
        }
        NSLayoutConstraint.activate(
            [
                titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                
                containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
                containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                
                userProfileImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 56),
                userProfileImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                userProfileImage.heightAnchor.constraint(equalToConstant: 96),
                userProfileImage.widthAnchor.constraint(equalToConstant: 96),
                
                summaryLabel.topAnchor.constraint(equalTo: userProfileImage.bottomAnchor, constant: 39),
                summaryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                summaryLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
                
                descriptionLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 11),
                descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
                
                addButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 28),
                addButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                addButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                addButton.heightAnchor.constraint(equalToConstant: 52),
                
                buttonView.leadingAnchor.constraint(equalTo: leadingAnchor),
                buttonView.trailingAnchor.constraint(equalTo: trailingAnchor),
                buttonView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
                buttonView.heightAnchor.constraint(equalToConstant: 125),
                
                bookButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 30),
                bookButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 16),
                bookButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -16),
                bookButton.heightAnchor.constraint(equalToConstant: 44),
                
                tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: buttonView.topAnchor)
            ]
        )
    }

}
