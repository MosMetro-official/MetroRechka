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
    
    private var searchResponse: RiverRouteResponse? {
        didSet {
            Task.detached { [weak self] in
                guard let self = self else { return}
                guard let state = await self.makeState() else { return }
                await self.setState(state)
            }
        }
    }
    
    let nestedView = PopularStationView(frame: UIScreen.main.bounds)
    
    public override func loadView() {
        self.view = nestedView
        setupSettingsActions()
        view.backgroundColor = Appearance.colors[.base]
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        Rechka.shared.token = "id46Uawk9YwxL_SdmTQjJ9zcu5V6_xbgVQRLST0rAgk"
        setOrderListener()
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.customFont(forTextStyle: .title1)
        ]
        title = "Популярное"
        self.nestedView.viewState = .init(state: [], dataState: .loading)
        Task.detached(priority: .high) {
            do {
                let routeResponse = try await RiverRoute.getRoutes()
                await self.setResponse(routeResponse)
                print("adadsdas")
            } catch {
                print("shiiiet")
            }
        }
        
        NotificationCenter.default.post(name: .riverShowOrder, object: nil, userInfo: ["orderID": 14])
    }
    
    @MainActor
    private func setResponse(_ response: RiverRouteResponse) async {
        self.searchResponse = response
    }
    
    @objc private func showOrder(from notification: Notification) {
        if let orderID = notification.userInfo?["orderID"] as? Int {
            print("Order: \(orderID)")
            let orderController = TicketDetailsController()
            self.present(orderController, animated: true) {
                orderController.orderID = orderID
            }
        }
    }
    
    private func setOrderListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(showOrder(from:)), name: .riverShowOrder, object: nil)
    }
    
    private func makeState() async -> PopularStationView.ViewState? {
        guard let searchResponse = searchResponse else {
            return nil
        }
        let elements: [Element] = searchResponse.items.map { route in
            let height = (UIScreen.main.bounds.width - 32) * 0.75
            let firstStation = route.stations.first?.name ?? ""
            let onPay: () -> () = { [weak self] in
                self?.pushDetail(with: route.id)
            }
            let routeData = PopularStationView.ViewState.Station(title: route.name,
                                                                 jetty: firstStation,
                                                                 time: "\(route.time) mins",
                                                                 tickets: true,
                                                                 price: "\(route.minPrice) ₽",
                                                                 height: height,
                                                                 onSelect: onPay)
                .toElement()
            return routeData
        }
        let section = SectionState(header: nil, footer: nil)
        let state = State(model: section, elements: elements)
        return PopularStationView.ViewState(state: [state], dataState: .loaded)
    }
    
    @MainActor
    func setState(_ state: PopularStationView.ViewState) {
        self.nestedView.viewState = state
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
        settingsView.onTerminalsButton = { [weak self] in
            guard let self = self else { return }
            struct Mock : _TicietsDetailsView { }
            let controller = TicketDetailsController()
            self.present(controller, animated: true)
//            if Rechka.isMapsAvailable {
//                self.openMapController()
//            } else {
//                self.openTerminalsTable()
//            }
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
        controller.shouldShowTerminalsButton = true
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
    
    private func pushDetail(with routeID: Int) {
        let detail = DetailStationController()
        navigationController?.pushViewController(detail, animated: true)
        detail.routeID = routeID
    }
}
