//
//  StationListView.swift
//  
//
//  Created by polykuzin on 16/03/2022.
//

import UIKit
import CoreTableView

final class StationListView : UIView {
    
    public var onMapTap : (() -> Void)?
    
    struct ViewState {
        
        var states : [State]
        
        struct Terminal : _TerminalCell {
            var title : String
            var descr : String
            var latitude : Double
            var longitude : Double
            var onSelect : (() -> Void)
        }
    }
    
    public var viewState = ViewState(states: []) {
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
        button.tintColor = .label
        button.backgroundColor = .cyan
        button.setTitle("На карте", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "map", in: .module, compatibleWith: nil), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstrains()
        mapButton.layer.cornerRadius = 20
        mapButton.backgroundColor = Appearance.colors[.content]
        backgroundColor = Appearance.colors[.base]
        self.mapButton.addTarget(
            self,
            action: #selector(openMap),
            for: .touchUpInside
        )
        if !Rechka.isMapsAvailable {
            mapButton.isHidden = true
        }
    }
    
    @objc
    private func openMap() {
        self.onMapTap?()
    }
    
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
