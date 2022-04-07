//
//  R_PassengerDataEntryView.swift
//  
//
//  Created by Слава Платонов on 23.03.2022.
//

import UIKit
import CoreTableView

internal final class R_PassengerDataEntryView: UIView {
    
    struct ViewState {
        
        var state: [State]
        let dataState: DataState
        let onReadySelect: Command<Void>?
        let validate: Bool
        
        enum DataState {
            case loading
            case loaded
        }
        
        struct Header: _Static {
            let title: String
        }
        
        struct Filed: _Field {
            let text: String
            let onSelect: () -> ()
        }
        
        struct GenderCell: _Gender {
            var gender: Gender
            let onTap: (Gender) -> ()
        }
        
        struct SelectField: _SelectCell {
            let title: String
            let onSelect: () -> ()
        }
        
        struct DocumentField: _Field {
            let text: String
            let onSelect: () -> ()
        }
        
        struct TariffHeader: _TicketsHeader {
            let title: String
            let ticketsCount: Int
            let isInsetGroup: Bool
        }
        
        struct Tickets: _Tickets {
            let ticketList: FakeModel
            let onChoice: ((Int) -> ())?
            let isSelectable: Bool
        }
        
        struct ChoicePlace: _ChoicePlace {
            let onSelect: Command<Void>?
        }
                
        static let initial = R_PassengerDataEntryView.ViewState(state: [], dataState: .loading, onReadySelect: nil, validate: false)
    }
    
    var viewState: ViewState = .initial {
        didSet {
            render()
        }
    }
    
    private var buttonView: UIView = {
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
        table.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorColor = .systemGray
        table.clipsToBounds = true
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.sectionFooterHeight = .leastNormalMagnitude
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 125, right: 0)
        return table
    }()
    
    private var bgBlurView : UIVisualEffectView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlur()
        setupConstrains()
        backgroundColor = .custom(for: .base)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func sendModelToBookingController() {
        viewState.onReadySelect?.perform(with: ())
    }
    
    private func setupButtonAction() {
        if viewState.validate {
            readyButton.addTarget(self, action: #selector(sendModelToBookingController), for: .touchUpInside)
            readyButton.alpha = 1
            readyButton.isEnabled = true
        } else {
            readyButton.alpha = 0.3
            readyButton.isEnabled = false
        }
    }
    
    private func setupBlur() {
        bgBlurView = UIVisualEffectView(frame: frame)
        let effect = UIBlurEffect(style: .systemChromeMaterial)
        bgBlurView.effect = effect
        self.buttonView.insertSubview(bgBlurView, at: 0)
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
            self.tableView.shouldUseReload = true
            self.setupButtonAction()
        }
    }

}
