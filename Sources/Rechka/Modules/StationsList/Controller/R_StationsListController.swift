//
//  R_StationsListController.swift
//  
//
//  Created by polykuzin on 15/03/2022.
//

import UIKit
import CoreTableView

internal final class R_StationsListController : UIViewController {
    
    var terminals = [R_Station]()
    var nestedView = R_StationListView(frame: UIScreen.main.bounds)
    
    override func loadView() {
        self.view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nestedView.onMapTap = {[weak self] in
            guard
                let self = self,
                let navigation = self.navigationController
            else { return }
            navigation.popViewController(animated: true)
        }
        navigationItem.hidesBackButton = true
        let backItem = UIBarButtonItem(
            image: UIImage(named: "backButton", in: .module, compatibleWith: nil)!,
            style: .plain,
            target: self,
            action: #selector(backButtonPressed)
        )
        navigationItem.leftBarButtonItem = backItem
        self.makeDummyState(with: self.terminals)
    }
    
    @objc
    private func backButtonPressed() {
        guard
            let navigation = self.navigationController,
            let controller = navigation.viewControllers.first
        else { return }
        navigation.popToViewController(controller, animated: true)
    }
    
    public func makeDummyState(with items: [R_Station]) {
        var elements = [Element]()
        for item in items {
            elements.append(
                R_StationListView.ViewState.Terminal(
                    title: item.name,
                    descr: item.cityName,
                    latitude: item.latitude,
                    longitude: item.longitude,
                    onSelect: {
                        item.onSelect()
                    }
                ).toElement()
            )
        }
        let section = SectionState(header: nil, footer: nil)
        let state = State(model: section, elements: elements)
        nestedView.viewState.states = [state]
    }
}
