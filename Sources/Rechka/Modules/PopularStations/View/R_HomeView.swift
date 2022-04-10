//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import UIKit
import CoreTableView

class R_HomeView: UIView {
    
    @IBOutlet weak var tableView: BaseTableView!
    
    
    @IBOutlet weak var clearButtonHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var verticalStackView: UIStackView!
    @IBOutlet weak var effectView: UIVisualEffectView!
    @IBOutlet weak var stationButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var categoriesButton: UIButton!
    
    enum ViewState {
        case loading
        case loaded(LoadedState)
        case error(R_Toast.Configuration)
        
        struct Button {
            let title: String
            let isDataSetted: Bool
            let onSelect: Command<Void>
            let listData: [ListItem]?
        }
        
        struct Station: _StationCell {
            let title: String
            let jetty: String
            let time: String
            let tickets: Bool
            let price: String
            let onSelect: (() -> Void)
        }
        
        struct Error: _R_ErrorCell {
            var image: UIImage
            
            var title: String
            
            var action: Command<Void>?
            
            var buttonTitle: String?
            
            var height: CGFloat
            
        }
        
        struct ListItem {
            let title: String
            let onSelect: Command<Void>
        }
        
        struct LoadMore: _RechkaLoadMoreCell {
            var onLoad: Command<Void>?
        }
        
        struct LoadedState {
            let dateButton: Button
            let stationButton: Button
            let categoriesButton: Button
            let clearButton: Button?
            let tableState: [State]
            
        }
    }
    
    
    var viewState: ViewState = .loading {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.render()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: self.effectView.frame.height, right: 0)
    }
    
    @IBAction func handleDate(_ sender: UIButton) {
        if case .loaded(let data) = viewState {
            data.dateButton.onSelect.perform(with: ())
        }
    }
    
    @IBAction func handleClear(_ sender: UIButton) {
        if case .loaded(let data) = viewState {
            data.clearButton?.onSelect.perform(with: ())
        }
    }
    
    @IBAction func handleStation(_ sender: UIButton) {
        if case .loaded(let data) = viewState {
            data.stationButton.onSelect.perform(with: ())
        }
    }
    
    @IBAction func handleCategories(_ sender: Any) {
        if case .loaded(let data) = viewState {
            data.categoriesButton.onSelect.perform(with: ())
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
}

extension R_HomeView {
    
    private func handle(button: UIButton, with state: ViewState.Button) {
        button.setTitle(state.title, for: .normal)
        button.setTitleColor(state.isDataSetted ? Appearance.colors[.textPrimary] : Appearance.colors[.textSecondary], for: .normal)
        if let listItems = state.listData {
            if #available(iOS 14.0, *) {
                button.showsMenuAsPrimaryAction = true
                let items: [UIAction] = listItems.map { menuItem in
                    return UIAction(title: menuItem.title, image: nil, handler: { _ in
                        menuItem.onSelect.perform(with: ())
                    })
                }
                
                let menu = UIMenu(title: "\(state.title)", image: nil, identifier: nil, children: items)
                button.menu = menu
            } 
        }
    }
    
    private func render() {
        switch viewState {
        case .loading:
            self.effectView.isHidden = true
            self.showBlurLoading()
            R_Toast.remove(from: self)
        case .loaded(let loadedState):
            self.effectView.isHidden = false
            self.removeBlurLoading()
            R_Toast.remove(from: self)
            self.tableView.viewStateInput = loadedState.tableState
            handle(button: categoriesButton, with: loadedState.categoriesButton)
            handle(button: dateButton, with: loadedState.dateButton)
            handle(button: stationButton, with: loadedState.stationButton)
            self.clearButtonHeightAnchor.constant = loadedState.clearButton == nil ? 0 : 40
            let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
                self.layoutSubviews()
                self.clearButton.alpha = loadedState.clearButton == nil ? 0 : 1
            }
            animator.startAnimation()
            
        case .error(let config):
            self.effectView.isHidden = true
            self.removeBlurLoading()
            R_Toast.show(on: self, with: config, distanceFromBottom: 24)
        }
    }
    
    private func setup() {
        tableView.shouldUseReload = true
        [dateButton,categoriesButton,stationButton].forEach {
            $0?.roundCorners(.all, radius: 20)
        }
        effectView.roundCorners(.top, radius: 10)
    }
    
}
