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
        
        var isChoiceButtonDisable: Bool
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
        
        struct DateHeader: _TripsDateHeader {
            var title: String
        }
        
        struct ShortTripInfo: _ShortTripTableCell {
            var date: String
            
            var isSelected: Bool
            
            var price: String
            
            var seats: String
            
            var onSelect: (() -> Void)
            
        }
        
      
        
       
     
        
        static let initial = DetailView.ViewState(isChoiceButtonDisable: false, state: [], dataState: .loading)
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
    
    internal var buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.isOpaque = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = UIScreen.main.displayCornerRadius
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
        return table
    }()
    
    var onClose: (() -> Void)?
    var onChoice: (() -> Void)?
    var posterHeaderView: PosterHeaderView?
    private var bgBlurView : UIVisualEffectView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bgBlurView = UIVisualEffectView(frame: frame)
        let effect = UIBlurEffect(style: .systemChromeMaterial)
        bgBlurView.effect = effect
        self.buttonView.insertSubview(bgBlurView, at: 0)
        posterHeaderView = PosterHeaderView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.width * 0.9))
        setupConstrains()
        setupHeaderView()
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 125, right: 0)
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
    
    private func disableChoiceButton() {
        choiceTicketButton.isEnabled = false
        choiceTicketButton.alpha = 0.3
    }
    
    private func setupHeaderView() {
        tableView.onScroll = { [weak self] scroll in
            guard let header = self?.tableView.tableHeaderView as? PosterHeaderView else { return }
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
            self.tableView.viewStateInput = self.viewState.state
            if self.viewState.isChoiceButtonDisable {
                self.disableChoiceButton()
            }
        }
    }
}
