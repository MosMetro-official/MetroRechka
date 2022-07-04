//
//  R_StationListView.swift
//  
//
//  Created by polykuzin on 16/03/2022.
//

import UIKit
import CoreTableView

internal final class R_StationListView : UIView {
        
    struct ViewState {
        var states : [State]
        var onMapTap : Command<Void>?
        
        struct Terminal : _TerminalCell {
            var id: String
            var title : String
            var descr : String
            var latitude : Double
            var longitude : Double
            var onSelect : (() -> Void)
        }
    }
    
    public var viewState = ViewState(states: [], onMapTap: nil) {
        didSet {
            DispatchQueue.main.async {
                self.tableView.viewStateInput = self.viewState.states
            }
        }
    }
    
    private let tableView : BaseTableView = {
        let table = BaseTableView(
            frame: UIScreen.main.bounds,
            style: .insetGrouped
        )
        table.clipsToBounds = true
        table.separatorStyle = .none
        table.separatorColor = .clear
        table.showsVerticalScrollIndicator = false
        table.showsHorizontalScrollIndicator = false
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let mapButton : UIButton = {
        let button = UIButton(
            frame: CGRect(x: 0, y: 0, width: 142, height: 40)
        )
        button.tintColor = Appearance.colors[.textInverted]
        button.setTitle("На карте", for: .normal)
        button.setTitleColor(Appearance.colors[.textInverted], for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "map", in: Rechka.shared.bundle, compatibleWith: nil), for: .normal)
        button.backgroundColor = Appearance.colors[.buttonSecondary]
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstrains()
        mapButton.addTarget(
            self,
            action: #selector(openMap),
            for: .touchUpInside
        )
        backgroundColor = UIColor.custom(for: .base)
        mapButton.layer.cornerRadius = 20
        if !Rechka.shared.isMapsAvailable {
            mapButton.isHidden = true
        }
    }
    
    @objc
    private func openMap() {
        viewState.onMapTap?.perform(with: ())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstrains() {
        addSubview(tableView)
        addSubview(mapButton)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10),
            
            mapButton.widthAnchor.constraint(equalToConstant: 142),
            mapButton.heightAnchor.constraint(equalToConstant: 40),
            mapButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            mapButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -54)
        ])
    }
}
