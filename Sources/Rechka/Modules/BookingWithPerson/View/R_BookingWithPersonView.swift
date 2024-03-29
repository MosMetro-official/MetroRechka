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
        let title : String
        let menuActions : [UIAction]
        var dataState : DataState
        let state: [State]
        var showPersonAlert : Command<Void>?
        var showPersonDataEntry : Command<Void>?
        var showUserFromCache : Command<R_User>?
        var book : Command<Void>?
        
        enum DataState {
            case addPersonData
            case addedPersonData
            case laoding
            case error(R_Toast.Configuration)
        }
        
        struct PassengerHeader : _PassengerHeaderCell {
            let onAdd : (() -> Void)
        }
        
        struct Passenger : _Passenger {
            let name : String
            let tariff : String
            let onSelect : (() -> Void)
        }
        
        struct TariffHeader: _TariffHeaderCell { }
        
        struct Tariff : _Tariff {
            let tariffs : String
            let price : String
        }
        
        struct Commission: _Commission {
            let commission : String
            let price : String
        }
        
        static let initial = R_BookingWithPersonView.ViewState(
            title: "",
            menuActions: [],
            dataState: .addPersonData,
            state: []
        )
    }
    
    public var viewState: R_BookingWithPersonView.ViewState = .initial {
        didSet {
            updateView()
            setupAddActions()
        }
    }
    
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
        view.backgroundColor = Appearance.colors[.base]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(forTextStyle: .title4)
        label.numberOfLines = 0
        label.textColor = .custom(for: .textPrimary)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userProfileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user_profile", in: Rechka.shared.bundle, with: nil)
        imageView.tintColor = UIColor.custom(for: .textPrimary)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "MoscowSans-Bold", size: 22)
        label.text = "Персональные данные"
        label.textColor = UIColor.custom(for: .textPrimary)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "MoscowSans-Regular", size: 15)
        label.text = "На данном рейсе необходимо указать персональные данные пассажиров"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .custom(for: .textSecondary)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить", for: .normal)
        button.setTitleColor(UIColor.custom(for: .textInverted), for: .normal)
        button.tintColor = .black
        button.clipsToBounds = true
        button.backgroundColor = .custom(for: .buttonSecondary)
        button.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 17)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .custom(for: .settingsPanel)
        view.isHidden = true
        view.clipsToBounds = true
        view.layer.isOpaque = false
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Забронировать", for: .normal)
        button.setTitleColor(UIColor.custom(for: .textInverted), for: .normal)
        button.tintColor = UIColor.custom(for: .textPrimary)
        button.backgroundColor = UIColor.custom(for: .buttonSecondary)
        button.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 16)
        button.layer.cornerRadius = 10
        button.titleLabel?.textAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Appearance.colors[.base]
        setupConstrains()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAddActions() {
        guard let users = SomeCache.shared.cache["user"] else { return }
        if !users.isEmpty {
            if #available(iOS 14, *) {
                addButton.showsMenuAsPrimaryAction = true
                addButton.menu = UIMenu(title: "Persons", children: viewState.menuActions)
            } else {
                addButton.addTarget(self, action: #selector(preseentPersonAlert), for: .touchUpInside)
            }
        } else {
            addButton.addTarget(self, action: #selector(pushPersonDataEntry), for: .touchUpInside)
            bookButton.addTarget(self, action: #selector(book), for: .touchUpInside)
        }
    }
    
    @objc
    private func book() {
        viewState.book?.perform(with: ())
    }
    
    @objc
    private func preseentPersonAlert() {
        viewState.showPersonAlert?.perform(with: ())
    }
    
    @objc
    private func pushPersonDataEntry() {
        viewState.showPersonDataEntry?.perform(with: ())
    }
    
    private func updateView() {
        DispatchQueue.main.async {
            self.titleLabel.text = self.viewState.title
            switch self.viewState.dataState {
            case .addPersonData:
                self.tableView.isHidden = true
            case .addedPersonData:
                R_Toast.remove(from: self)
                self.containerView.isHidden = true
                self.tableView.isHidden = false
                self.buttonView.isHidden = false
                self.tableView.viewStateInput = self.viewState.state
            case .laoding:
                R_Toast.remove(from: self)
                self.showBlurLoading()
            case .error(let config):
                self.removeBlurLoading()
                self.tableView.isHidden = false
                self.buttonView.isHidden = true
                self.tableView.viewStateInput = self.viewState.state
                R_Toast.show(on: self, with: config, distanceFromBottom: 24)
            }
        }
    }
}

extension R_BookingWithPersonView {
    
    private func setupConstrains() {
        addSubview(containerView)
        addSubview(tableView)
        addSubview(titleLabel)
        addSubview(buttonView)
        buttonView.addSubview(bookButton)
        [
            addButton,
            summaryLabel,
            userProfileImage,
            descriptionLabel
        ].forEach {
            containerView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            userProfileImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 56),
            userProfileImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            userProfileImage.heightAnchor.constraint(equalToConstant: 68),
            userProfileImage.widthAnchor.constraint(equalToConstant: 80),
            
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
        ])
    }
}
