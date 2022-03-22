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
        
        struct TicketsHeader: _TicketsHeader {
            let ticketsCount: Int
            let height: CGFloat
        }
        
        struct Tickets: _Tickets {
            var ticketList: FakeModel
            let height: CGFloat
        }
        
        struct RefundHeader: _RefundHeader {
            let height: CGFloat
            var isExpanded: Bool
            var onExpandTap: () -> ()
        }
        
        struct AboutRefund: _Refund {
            let height: CGFloat
        }
        
        struct PackageHeader: _PackageHeader {
            let height: CGFloat
            var isExpanded: Bool
            var onExpandTap: () -> ()
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
    
    internal let backButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "back", in: .module, with: nil), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(popToRoot), for: .touchUpInside)
        return button
    }()
    
    internal let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .settingsPanel
        view.layer.isOpaque = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = UIScreen.main.displayCornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    internal let choiceTicketButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.tintColor = .black
        button.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 10
        button.setTitle("Выбрать билеты", for: .normal)
        button.addTarget(self, action: #selector(goToChoiceTickets), for: .touchUpInside)
        return button
    }()

    private lazy var tableView: BaseTableView = {
        let table = BaseTableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorColor = .clear
        table.clipsToBounds = true
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.tableHeaderView = posterHeaderView
        return table
    }()
    
    var posterHeaderView: PosterHeaderView?
    var onClose: (() -> Void)?
    var onChoice: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        posterHeaderView = PosterHeaderView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.width * 0.9))
        setupConstrains()
        setupHeaderView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func goToChoiceTickets() {
        onChoice?()
    }
    
    @objc private func popToRoot() {
        onClose?()
    }
    
    private func setupHeaderView() {
        tableView.onScroll = { scroll in
            guard let header = self.tableView.tableHeaderView as? PosterHeaderView else { return }
            header.scrollViewDidScroll(scrollView: scroll)
        }
    }
        
    private func setupConstrains() {
        addSubview(tableView)
        addSubview(buttonView)
        addSubview(backButton)
        buttonView.addSubview(choiceTicketButton)
        NSLayoutConstraint.activate(
            [
                tableView.topAnchor.constraint(equalTo: topAnchor),
                tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: buttonView.topAnchor),
                
                buttonView.leadingAnchor.constraint(equalTo: leadingAnchor),
                buttonView.trailingAnchor.constraint(equalTo: trailingAnchor),
                buttonView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
                buttonView.heightAnchor.constraint(equalToConstant: 106),
                
                choiceTicketButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 20),
                choiceTicketButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 16),
                choiceTicketButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -16),
                choiceTicketButton.heightAnchor.constraint(equalToConstant: 44),
                
                backButton.topAnchor.constraint(equalTo: topAnchor, constant: 52),
                backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                backButton.widthAnchor.constraint(equalToConstant: 32),
                backButton.heightAnchor.constraint(equalToConstant: 32)
            ]
        )
    }
    
    private func render() {
        DispatchQueue.main.async {
            self.tableView.viewStateInput = self.viewState.state
        }
    }
}
