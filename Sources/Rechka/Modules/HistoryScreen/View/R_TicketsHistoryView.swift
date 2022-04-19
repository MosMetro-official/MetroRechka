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
            case error(R_Toast.Configuration)
        }
        
        struct HistoryTicket: _History {
            let title : String
            let descr : String
            let price : String
            let onSelect : (() -> Void)
        }
        
        struct Empty: _R_EmptyTableViewCell {
            var title: String
            
            var image: UIImage
        }
        
        struct DateHeader: _TripsDateHeader {
            var title: String
        }
        
        struct LoadMore: _RechkaLoadMoreCell {
            var onLoad: Command<Void>?
        }
        
        static let initial = R_TicketsHistoryView.ViewState(state: [], dataState: .loading)
    }
    
    public var viewState: R_TicketsHistoryView.ViewState = .initial {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.render()
            }
            
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
    }
    
    @available(*, unavailable)
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
                R_Toast.remove(from: self)
                self.removeBlurLoading(from: self)
            case .loading:
                R_Toast.remove(from: self)
                self.showBlurLoading(on: self)
            case .error(let config):
                self.removeBlurLoading(from: self)
                R_Toast.show(on: self, with: config)
            }
            self.tableView.viewStateInput = self.viewState.state
        }
    }
}
