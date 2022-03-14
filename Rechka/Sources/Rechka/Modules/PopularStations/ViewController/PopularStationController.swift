//
//  RiverStationController.swift
//  
//
//  Created by Слава Платонов on 06.03.2022.
//

import UIKit
import CoreTableView

public class PopularStationController: UIViewController {
        
    let nestedView = PopularStationView(frame: UIScreen.main.bounds)
    
    public override func loadView() {
        self.view = nestedView
        view.backgroundColor = Appearance.colors[.base]
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.customFont(forTextStyle: .title1)
        ]
        title = "Популярное"
        makeState()
    }
    
    private func makeState() {
        let elements = mockElements()
        let section = SectionState(header: nil, footer: nil)
        let state = State(model: section, elements: elements)
        nestedView.viewState = PopularStationView.ViewState(state: [state], dataState: .loaded)
    }
}

extension PopularStationController {
    
    private func pushDetail(with model: FakeModel) {
        let detail = DetailStationController()
        detail.model = model
        navigationController?.pushViewController(detail, animated: true)
    }
    
    private func mockElements() -> [Element] {
        let elements = FakeModel.getModels().map { model -> Element in
            let element = PopularStationView.ViewState.Station(title: model.title, jetty: model.jetty, time: model.time, tickets: model.tickets, price: model.price, height: 250, onPay: { self.pushDetail(with: model) }).toElement()
            return element
        }
        return elements
    }
}
