//
//  R_TicketsHistoryView.swift
//  
//
//  Created by Слава Платонов on 29.03.2022.
//

import UIKit
import CoreTableView

internal final class R_TicketsHistoryView: UIView {

    struct ViewState {
        
        let state: [State]
        let dataState: DataState
        
        enum DataState {
            case loaded
            case loading
        }
        
        struct HistoryTicket: _History {
            let title : String
            let descr : String
            let price : String
            let onSelect : (() -> Void)
        }
        
        static let initial = R_TicketsHistoryView.ViewState(state: [], dataState: .loading)
    }
    
    public var viewState: R_TicketsHistoryView.ViewState = .initial {
        didSet {
            render()
        }
    }
    
    private let tableView: BaseTableView = {
        let table = BaseTableView(frame: .zero, style: .insetGrouped)
        table.clipsToBounds = true
        table.separatorColor = .systemGray
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.sectionFooterHeight = .leastNormalMagnitude
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstrains()
        backgroundColor = .custom(for: .base)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstrains() {
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func render() {
        DispatchQueue.main.async {
            self.tableView.viewStateInput = self.viewState.state
        }
    }
}
