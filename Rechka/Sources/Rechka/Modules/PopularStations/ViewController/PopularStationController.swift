//
//  RiverStationController.swift
//  
//
//  Created by Слава Платонов on 06.03.2022.
//

import UIKit
import CoreTableView

public class PopularStationController: UIViewController {
    
    var delegate : RechkaMapDelegate?
    var reverceDelegate : RechkaMapReverceDelegate?
    
    var terminals : [_RechkaTerminal] {
        return [
            FakeTerminal(
                title: "Парк \"Зарядье\"",
                descr: "Москва",
                latitude: 55.7522200,
                longitude: 37.6155600,
                onSelect: { [weak self] in
                    // ТУт ловим нужное от нажатия на пин
                    guard
                        let self = self,
                        let navigation = self.navigationController
                    else { return }
                    navigation.popViewController(animated: true)
                }
            )
        ]
    }
    
    let nestedView = PopularStationView(frame: UIScreen.main.bounds)
    
    public override func loadView() {
        self.view = nestedView
        setupSettingsActions()
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
    
    private func setupSettingsActions() {
        guard let settingsView = nestedView.settingsView as? BottomSettingsView else { return }
        settingsView.onDatesMenu = { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: "😐😐😐😐", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "🕐🔨🏞", style: .default, handler: { _ in
                alert.dismiss(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        settingsView.onTerminalsButton = {[weak self] in
            guard let self = self else { return }
            if Rechka.isMapsAvailable {
                self.openMapController()
            } else {
                self.openTerminalsTable()
            }
        }
    }
    
    private func openTerminalsTable() { }
    
    private func openMapController() {
        let controller = delegate?.getRechkaMapController()
        guard
            let controller = controller,
            let navigation = navigationController
        else { fatalError() }
        controller.delegate = self
        navigation.pushViewController(controller, animated: true)
        var points = [UIImage]()
        for terminal in terminals {
            points.append(Appearance.makeRechkaTerminalImage(from: terminal))
        }
        controller.terminals = terminals
        controller.terminalsImages = points
    }
}

extension PopularStationController : RechkaMapReverceDelegate {
    
    public func onMapBackSelect() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    public func onTerminalsListSelect() {
//        self.navigationController?.pushViewController(<#T##viewController: UIViewController##UIViewController#>, animated: <#T##Bool#>)
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
            let element = PopularStationView.ViewState.Station(title: model.title, jetty: model.jetty, time: model.time, tickets: model.ticketsCount < 3, price: model.price, height: 250, onPay: { self.pushDetail(with: model) }).toElement()
            return element
        }
        return elements
    }
}
