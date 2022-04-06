//
//  HistoryView.swift
//  
//
//  Created by Слава Платонов on 29.03.2022.
//

import UIKit
import CoreTableView

class HistoryView: UIView {

    struct ViewState {
        
        let state: [State]
        let dataState: DataState
        
        enum DataState {
            case loaded
            case loading
            case error
        }
        
        struct HistoryTicket: _History {
            let title : String
            let descr : String
            let price : String
            let onSelect : (() -> Void)
        }
        
        struct DateHeader: _TripsDateHeader {
            var title: String
        }
        
        struct LoadMore: _RechkaLoadMoreCell {
            var onLoad: Command<Void>?
        }
        
        static let initial = HistoryView.ViewState(state: [], dataState: .loading)
    }
    
    public var viewState: HistoryView.ViewState = .initial {
        didSet {
            render()
        }
    }
    
    public var onWillDisplay: ((CellWillDisplayData) -> Void)?
    
    private let tableView: BaseTableView = {
        let table = BaseTableView(frame: .zero, style: .grouped)
        table.clipsToBounds = true
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.sectionFooterHeight = .leastNormalMagnitude
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = Appearance.colors[.base]
        table.shouldUseReload = true
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstrains()
        backgroundColor = .custom(for: .base)
        tableView.onWillDisplay = { [weak self] displayData in
            guard let self = self else { return }
            self.onWillDisplay?(displayData)
        }
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
        DispatchQueue.main.async { [self] in
            switch self.viewState.dataState {
            case .loaded:
                self.removeBlurLoading(from: self)
            case .loading:
                self.showBlurLoading(on: self)
            case .error:
                self.removeBlurLoading(from: self)
            }
            self.tableView.viewStateInput = self.viewState.state
        }
    }
}
