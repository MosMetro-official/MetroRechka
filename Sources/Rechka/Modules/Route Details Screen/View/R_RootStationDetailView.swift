//
//  R_RootDetailStationView.swift
//  
//
//  Created by Слава Платонов on 16.03.2022.
//

import UIKit
import CoreTableView

internal final class R_RootDetailStationView: UIView {
    
    struct ViewState {
        let state: [State]
        let dataState: DataState
        let onChoice: Command<Void>?
        let onClose: Command<Void>?
        let posterTitle: String
        let posterImageURL: String?
        
        enum DataState {
            case loading
            case loaded
            case error(R_Toast.Configuration)
        }
        
        struct Summary: _Summary {
            var text: NSAttributedString
            
            var onMore: Command<Void>?
            
            var height: CGFloat

        }
        
        struct MapView: _MapView {
            let onButtonSelect: () -> ()
        }
        
        struct DateHeader: _TripsDateHeader {
            var title: String
        }
        
        
        struct Trips: _TripSelectionCell {
            
            var day: String
            
            var items: [_R_DateCollectionCell]
            
            var shouldScrollToInitial: Bool
        }
        
        struct TripTime: _R_DateCollectionCell {
            var time: String
            
            var textColor: UIColor
            
            var bgColor: UIColor
            
            var borderColor: UIColor
            
            var onSelect: Command<Void>
        
        }
        
        struct Error: _R_ErrorCell {
            var image: UIImage
            
            var title: String
            
            var action: Command<Void>?
            
            var buttonTitle: String?
            
            var height: CGFloat
        }
        
        static let initial = R_RootDetailStationView.ViewState(state: [], dataState: .loading, onChoice: nil, onClose: nil, posterTitle: "", posterImageURL: nil)
    }
    
    var viewState: ViewState = .initial {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.render()
            }
        }
    }
    
    internal let backButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "back", in: .module, with: nil), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(popToRoot), for: .touchUpInside)
        return button
    }()
    
    internal var buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.isOpaque = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()
    
    internal let choiceTicketButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.custom(for: .buttonSecondary)
        button.tintColor = UIColor.custom(for: .textPrimary)
        button.setTitleColor(UIColor.custom(for: .textInverted), for: .normal)
        button.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 10
        button.setTitle("Выбрать билеты", for: .normal)
        button.addTarget(self, action: #selector(goToChoiceTickets), for: .touchUpInside)
        return button
    }()
    
     lazy var tableView: BaseTableView = {
        let table = BaseTableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorColor = .clear
        table.clipsToBounds = true
        table.shouldUseReload = true
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.tableHeaderView = posterHeaderView
         table.backgroundColor = Appearance.colors[.base]
        return table
    }()
    
    private var posterHeaderView: R_PosterTableHeaderView?
    private var bgBlurView : UIVisualEffectView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bgBlurView = UIVisualEffectView(frame: frame)
        let effect = UIBlurEffect(style: .systemChromeMaterial)
        bgBlurView.effect = effect
        self.buttonView.insertSubview(bgBlurView, at: 0)
        posterHeaderView = R_PosterTableHeaderView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.width * 0.9))
        setupConstrains()
        setupHeaderView()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 125, right: 0)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func goToChoiceTickets() {
        self.viewState.onChoice?.perform(with: ())
    }
    
    @objc private func popToRoot() {
        self.viewState.onClose?.perform(with: ())
    }
    
    private func setupHeaderView() {
        tableView.onScroll = { [weak self] scroll in
            guard let header = self?.tableView.tableHeaderView as? R_PosterTableHeaderView else { return }
            header.scrollViewDidScroll(scrollView: scroll)
        }
    }
    
    private func setupConstrains() {
        addSubview(tableView)
        addSubview(buttonView)
        addSubview(backButton)
        buttonView.addSubview(choiceTicketButton)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            buttonView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
            buttonView.heightAnchor.constraint(equalToConstant: 125),
            
            choiceTicketButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 30),
            choiceTicketButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 16),
            choiceTicketButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -16),
            choiceTicketButton.heightAnchor.constraint(equalToConstant: 44),
            
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 52),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func render() {
        DispatchQueue.main.async {
            switch self.viewState.dataState {
            case .loading:
                self.buttonView.isHidden = true
                R_Toast.remove(from: self)
                self.showBlurLoading()
            case .loaded:
                self.buttonView.isHidden = false
                R_Toast.remove(from: self)
                self.removeBlurLoading()
            case .error(let config):
                self.buttonView.isHidden = true
                self.removeBlurLoading()
                R_Toast.show(on: self, with: config)
            }
            self.posterHeaderView?.configurePosterHeader(with: self.viewState.posterTitle, and: self.viewState.posterImageURL)
            self.choiceTicketButton.alpha = self.viewState.onChoice == nil ? 0.4 : 1
            self.choiceTicketButton.isUserInteractionEnabled = self.viewState.onChoice == nil ? false : true
            self.tableView.viewStateInput = self.viewState.state
        }
    }
}
