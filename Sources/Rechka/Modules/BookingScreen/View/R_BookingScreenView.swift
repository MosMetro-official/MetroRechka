//
//  R_BookingScreenView.swift
//  
//
//  Created by polykuzin on 24/03/2022.
//

import UIKit
import CoreTableView

internal final class R_BookingScreenView : UIView {
    
    @objc
    private func popToRoot() {
        self.viewState.onClose?.perform(with: ())
    }
    
    @objc
    private func paySelected() {
        self.viewState.onPay?.perform(with: ())
    }
    
    struct ViewState {
        var dataState: DataState
        var states : [State]
        var onClose: Command<Void>?
        var onPay: Command<Void>?
        var totalPrice: String
        
        enum DataState {
            case loading
            case loaded
            case error(R_Toast.Configuration)
        }
        
        struct Title : _Title {
            var title : String
            var height: CGFloat
        }
        
        struct Timer : _Timer {
            var timer : String
            var descr : String
        }
        
        
        
        struct Cancel : _Cancel {
            var title : String
            var onSelect: (() -> Void)
        }
    }
    
    public var viewState = ViewState(dataState: .loading, states: [], onClose: nil, onPay: nil, totalPrice: "") {
        didSet {
            DispatchQueue.main.async {
                self.render()
            }
        }
    }
    
    private func render() {
        switch self.viewState.dataState {
        case .loading:
            R_Toast.remove(from: self)
            self.showBlurLoading()
        case .loaded:
            R_Toast.remove(from: self)
            self.removeBlurLoading()
        case .error(let config):
            self.removeBlurLoading()
            R_Toast.show(on: self, with: config, distanceFromBottom: self.bgBlurView.frame.height)
        }
        self.paySumm.text = self.viewState.totalPrice
        self.payButton.alpha = self.viewState.onPay == nil ? 0.3 : 1
        self.payButton.isUserInteractionEnabled = self.viewState.onPay == nil ? false : true
        self.tableView.viewStateInput = self.viewState.states
    }
    
    private var payView : UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.isOpaque = false
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private var paySumm : UILabel = {
        let title = UILabel()
        title.text = "2200 ₽"
        title.font = .customFont(forTextStyle: .body)
        title.textColor = .custom(for: .buttonSecondary)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private var payTitle : UILabel = {
        let title = UILabel()
        title.text = "ИТОГО"
        title.font = .customFont(forTextStyle: .caption1)
        title.textColor = .custom(for: .textSecondary)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private var payButton : UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.setTitle("Оплатить", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.tintColor = UIColor.custom(for: .textPrimary)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.custom(for: .buttonSecondary)
        button.titleLabel?.font = UIFont(name: "MoscowSans-Regular", size: 16)
        button.setTitleColor(UIColor.custom(for: .textInverted), for: .normal)
        button.addTarget(self, action: #selector(paySelected), for: .touchUpInside)
        return button
    }()
    
    private var tableView : BaseTableView = {
        let table = BaseTableView(frame: .zero, style: .insetGrouped)
        table.clipsToBounds = true
        table.separatorColor = .clear
        table.shouldUseReload = true
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .custom(for: .base)
        table.showsHorizontalScrollIndicator = false
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    internal let backButton : UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "cross", in: .module, with: nil), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(popToRoot), for: .touchUpInside)
        return button
    }()
    
    private var bgBlurView : UIVisualEffectView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        self.setupConstraints()
        self.tableView.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .custom(for: .base)
        bgBlurView = UIVisualEffectView(frame: frame)
        let effect = UIBlurEffect(style: .systemChromeMaterial)
        bgBlurView.effect = effect
        self.payView.insertSubview(bgBlurView, at: 0)
    }
    
    private func setupConstraints() {
        addSubview(tableView)
        addSubview(payView)
        addSubview(paySumm)
        addSubview(payTitle)
        addSubview(backButton)
        payView.addSubview(payButton)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            payView.leadingAnchor.constraint(equalTo: leadingAnchor),
            payView.trailingAnchor.constraint(equalTo: trailingAnchor),
            payView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
            payView.heightAnchor.constraint(equalToConstant: 125),
            
            payTitle.topAnchor.constraint(equalTo: payView.topAnchor, constant: 30),
            payTitle.leadingAnchor.constraint(equalTo: payView.leadingAnchor, constant: 20),
            payTitle.heightAnchor.constraint(equalToConstant: 13),
            
            paySumm.topAnchor.constraint(equalTo: payTitle.bottomAnchor, constant: 4),
            paySumm.leadingAnchor.constraint(equalTo: payView.leadingAnchor, constant: 20),
            paySumm.heightAnchor.constraint(equalToConstant: 23),
            
            payButton.topAnchor.constraint(equalTo: payView.topAnchor, constant: 30),
            payButton.leadingAnchor.constraint(equalTo: payView.leadingAnchor, constant: 100),
            payButton.trailingAnchor.constraint(equalTo: payView.trailingAnchor, constant: -20),
            payButton.heightAnchor.constraint(equalToConstant: 44),
            
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            backButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
}
