//
//  DetailView.swift
//  
//
//  Created by Слава Платонов on 16.03.2022.
//

import UIKit
import CoreTableView

class DetailView: UIView {
    
    struct ViewState {
        
        let state: [State]
        let dataState: DataState
        
        enum DataState {
            case loading
            case loaded
            case error
        }
        
        struct Summary: _Suumary {            
            let duration: String
            let fromTo: String
            let height: CGFloat
        }
        
        struct MapView: _MapView {
            let onButtonSelect: () -> ()
            let height: CGFloat
        }
        
        struct Tickets {
            let tickets: [FakeTickets]
        }
        
        struct RefundHeader: _RefundHeader {
            let height: CGFloat
            var isExpanded: Bool
            var onSelect: () -> ()
        }
        
        struct AboutRefund: _Refund {
            let height: CGFloat
        }
        
        struct PackageHeader: _PackageHeader {
            let height: CGFloat
            var isExpanded: Bool
            var onSelect: () -> ()
        }
        
        struct AboutPackage: _Package {
            let height: CGFloat
        }
        
        static let initial = DetailView.ViewState(state: [], dataState: .loading)
    }
        
    var viewState: ViewState = .initial {
        didSet {
            render()
        }
    }
    
    var posterHeaderView: PosterHeaderView?

    private lazy var tableView: BaseTableView = {
        let table = BaseTableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorColor = .clear
        table.clipsToBounds = true
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.tableHeaderView = posterHeaderView
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        posterHeaderView = PosterHeaderView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.width))
        setupConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupConstrains() {
        addSubview(tableView)
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: topAnchor),
                tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        )
        
        tableView.onScroll = { scrollView in
            guard let header = self.tableView.tableHeaderView as? PosterHeaderView else { return }
            header.scrollViewDidScroll(scrollView: scrollView)
        }
    }
    
    private func render() {
        self.tableView.viewStateInput = self.viewState.state
    }
}
