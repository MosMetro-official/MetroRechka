//
//  R_PopularStationsView.swift
//  
//
//  Created by Слава Платонов on 08.03.2022.
//

import UIKit
import CoreTableView

internal final class R_PopularStationsView: UIView {
        
    struct ViewState {
        
        var state: [State]
        var dataState: DataState
        
        enum DataState {
            case loading
            case loaded
            case error
        }
        
        struct Station: _StationCell {
            let title: String
            let jetty: String
            let time: String
            let tickets: Bool
            let price: String
            let onSelect: (() -> Void)
        }
                        
        static let initial = R_PopularStationsView.ViewState(state: [], dataState: .loading)
    }
    
    var viewState: ViewState = .initial {
        didSet {
            render()
        }
    }
    
    private var tableView: BaseTableView = {
        let table = BaseTableView(frame: .zero, style: .plain)
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorColor = .clear
        table.clipsToBounds = true
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        return table
    }()
    
    internal let settingsView: UIView = {
        let view = R_BottomSettingsView()
        view.layer.isOpaque = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = UIScreen.main.displayCornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstrains()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bounds.height / 5, right: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstrains() {
        addSubview(tableView)
        addSubview(settingsView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
                
            settingsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            settingsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            settingsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
            settingsView.heightAnchor.constraint(equalToConstant: bounds.height / 5)
        ])
    }
    
    private func render() {
        DispatchQueue.main.async {
            self.tableView.viewStateInput = self.viewState.state
        }
    }
}