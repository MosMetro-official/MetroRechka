//
//  WithoutPersonBookingView.swift
//  
//
//  Created by Слава Платонов on 25.03.2022.
//

import UIKit
import CoreTableView

class WithoutPersonBookingView: UIView {
    
    struct ViewState {
        
        var title: String
        var state: [State]
        var dataState: DataState
        
        enum DataState {
            case loading
            case loaded
        }
        
        struct TariffSteper: _TariffSteper {
            let tariff: String
            var price: String
            var stepperCount: String
            var onPlus: (Int) -> ()
            var onMinus: (Int) -> ()
            let height: CGFloat
        }
        
        struct ChoicePlace: _ChoicePlace {
            let onSelect: () -> ()
            let height: CGFloat
        }
        
        static let initial = WithoutPersonBookingView.ViewState(title: "", state: [], dataState: .loading)
    }
    
    var viewState: ViewState = .initial {
        didSet {
            render()
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "MoscowSans-Bold", size: 22)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .custom(for: .textPrimary)
        return label
    }()
    
    private let tableView: BaseTableView = {
        let table = BaseTableView(frame: .zero, style: .insetGrouped)
        table.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorColor = .clear
        table.clipsToBounds = true
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.sectionFooterHeight = .leastNormalMagnitude
        return table
    }()
    
    private let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .custom(for: .settingsPanel)
        view.layer.isOpaque = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = UIScreen.main.displayCornerRadius
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
        setupConstrains()
        backgroundColor = Appearance.colors[.base]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func render() {
        DispatchQueue.main.async {
            self.titleLabel.text = self.viewState.title
            self.tableView.viewStateInput = self.viewState.state
        }
    }
    
    private func setupConstrains() {
        addSubview(tableView)
        addSubview(buttonView)
        addSubview(titleLabel)
        buttonView.addSubview(bookButton)
        
        NSLayoutConstraint.activate(
            [
                titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                
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
