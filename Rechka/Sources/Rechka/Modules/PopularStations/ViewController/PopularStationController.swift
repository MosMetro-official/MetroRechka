//
//  RiverStationController.swift
//  
//
//  Created by Слава Платонов on 06.03.2022.
//

import UIKit
import CoreTableView

public class PopularStationController : UIViewController {
    
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
                    guard
                        let self = self,
                        let navigation = self.navigationController,
                        let controller = navigation.viewControllers.first
                    else { return }
                    navigation.popToViewController(controller, animated: true)
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
        settingsView.onCategoriesMenu = { [weak self] in
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
        settingsView.onPersonsMenu = { [weak self] persons in
            guard let self = self else { return }
            self.handle(persons)
        }
        settingsView.swowDatesAlert = { [weak self] in
            guard let self = self else { return }
            let myDatePicker: UIDatePicker = UIDatePicker()
            myDatePicker.timeZone = .current
            if #available(iOS 13.4, *) {
                myDatePicker.preferredDatePickerStyle = .wheels
            }
            myDatePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200)
            let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
            
            alertController.view.addSubview(myDatePicker)
            let selectAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
                print("Selected Date: \(myDatePicker.date)")
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(selectAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
        }
        settingsView.swowPersonsAlert = { [weak self] in
            guard let self = self else { return }
            let optionMenu = UIAlertController(title: nil, message: "Persons", preferredStyle: .actionSheet)
            let partyAction = UIAlertAction(title: "Пятеро 🥳", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.handle(5)
            })
            let bigFamilyAction = UIAlertAction(title: "Четверо 👨‍👩‍👧‍👦", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.handle(4)
            })
            let smallFamilyAction = UIAlertAction(title: "Трое 👨‍👩‍👦", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.handle(3)
            })
            let coupleAction = UIAlertAction(title: "Двое 👨‍❤️‍👨", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.handle(2)
            })
            let lonelyAction = UIAlertAction(title: "Для одного 👩", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.handle(1)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            optionMenu.addAction(partyAction)
            optionMenu.addAction(bigFamilyAction)
            optionMenu.addAction(smallFamilyAction)
            optionMenu.addAction(coupleAction)
            optionMenu.addAction(lonelyAction)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    private func handle(_ persons: Int) { }
    
    private func openTerminalsTable() {
        self.onTerminalsListSelect()
    }
    
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
        let controller = StationsListController()
        controller.terminals = terminals
        self.navigationController?.pushViewController(controller, animated: true)
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
