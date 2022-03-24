//
//  PassengerDataEntryView.swift
//  
//
//  Created by Слава Платонов on 23.03.2022.
//

import UIKit
import CoreTableView

class PassengerDataEntryView: UIView {
    
    struct ViewState {
        
        var state: [State]
        let dataState: DataState
        
        enum DataState {
            case loading
            case loaded
        }
        
        struct PersonHeader: _Static {
            let title: String
            let height: CGFloat
        }
        
        struct NameField: _Field {
            let placeholder: String
            let onTap: () -> ()
            let onFieldEdit: (UITextField) -> ()
            let height: CGFloat
        }
        
        struct SurnameField: _Field {
            let placeholder: String
            let onTap: () -> ()
            let onFieldEdit: (UITextField) -> ()
            let height: CGFloat
        }
        
        struct PatronymicFiled: _Field {
            let placeholder: String
            let onTap: () -> ()
            let onFieldEdit: (UITextField) -> ()
            let height: CGFloat
        }
        
        struct BirthdayField: _Field {
            let placeholder: String
            let textFieldType: UIKeyboardType
            let onTap: () -> ()
            let onFieldEdit: (UITextField) -> ()
            let height: CGFloat
        }
        
        struct NumberFiled: _Field {
            let placeholder: String
            let textFieldType: UIKeyboardType
            let onTap: () -> ()
            let onFieldEdit: (UITextField) -> ()
            let height: CGFloat
        }
        
        struct GenderCell: _Gender {
            let gender: Gender
            let onTap: (Gender) -> ()
            let height: CGFloat
        }
        
        struct CitizenshipHeader: _Static {
            let title: String
            let height: CGFloat
        }
        
        struct CitizenshipCell: _Citizen {
            let title: String
            let onSelect: () -> ()
            let height: CGFloat
        }
        
        struct DocumentHeader: _Static {
            let title: String
            let height: CGFloat
        }
        
        struct DocumentCell: _Document {
            let title: String
            let onSelect: () -> ()
            let height: CGFloat
        }
        
        struct DocumentField: _Field {
            let placeholder: String
            let textFieldType: UIKeyboardType
            let onTap: () -> ()
            let onFieldEdit: (UITextField) -> ()
            let height: CGFloat
        }
        
        struct TariffHeader {
            let title: String
        }
        
        struct TariffCell {
            let tariffs: FakeModel
            let onSelect: () -> ()
        }
        
        static let initial = PassengerDataEntryView.ViewState(state: [], dataState: .loading)
    }
    
    var viewState: ViewState = .initial {
        didSet {
            render()
        }
    }
    
    var validate: (() -> Bool)? = { return false } {
        didSet {
            setupButtonAction()
        }
    }
    
    var onReadySelect: (() -> ())?
    
    private let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.isOpaque = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = UIScreen.main.displayCornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    private let readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.custom(for: .buttonSecondary)
        button.tintColor = UIColor.custom(for: .textPrimary)
        button.setTitleColor(UIColor.custom(for: .textInverted), for: .normal)
        button.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 10
        button.setTitle("Готово", for: .normal)
        return button
    }()
    
    private let tableView: BaseTableView = {
        let table = BaseTableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorColor = .systemGray
        table.clipsToBounds = true
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstrains()
        setupButtonAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func sendModelToBookingController() {
        onReadySelect?()
    }
    
    private func setupButtonAction() {
        guard let valid = validate?() else { return }
        if valid {
            readyButton.addTarget(self, action: #selector(sendModelToBookingController), for: .touchUpInside)
            readyButton.alpha = 1
            readyButton.isEnabled = true
        } else {
            readyButton.alpha = 0.3
            readyButton.isEnabled = false
        }
    }
    
    private func setupConstrains() {
        addSubview(tableView)
        addSubview(buttonView)
        buttonView.addSubview(readyButton)
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: topAnchor),
                tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                buttonView.leadingAnchor.constraint(equalTo: leadingAnchor),
                buttonView.trailingAnchor.constraint(equalTo: trailingAnchor),
                buttonView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
                buttonView.heightAnchor.constraint(equalToConstant: 125),
                
                readyButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 30),
                readyButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 16),
                readyButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -16),
                readyButton.heightAnchor.constraint(equalToConstant: 44)
            ]
        )
    }

    private func render() {
        DispatchQueue.main.async {
            self.tableView.viewStateInput = self.viewState.state
        }
    }

}
