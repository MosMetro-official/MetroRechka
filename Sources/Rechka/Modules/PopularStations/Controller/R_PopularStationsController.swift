//
//  R_PopularStationsController.swift
//  
//
//  Created by Слава Платонов on 06.03.2022.
//

import UIKit
import CoreTableView
import CoreNetwork
import SwiftDate


internal final class R_PopularStationsController : UIViewController {
    
    var delegate : RechkaMapDelegate?
    
    var reverceDelegate : RechkaMapReverceDelegate?
    
    var terminals = [R_Station]()
    
    struct SearchModel {
        var selectedTags: [String]
        var date: Date?
        var station: R_Station?
    }
    
    
    private var isNeedToShowLoading = true
    
    private let service = R_Service()
    
    private var searchResponse: R_RouteResponse? {
        didSet {
            Task.detached { [weak self] in
                guard let self = self else { return}
                await self.makeState()
            }
        }
    }
    
    private var isLoading = false {
        didSet {
            Task.detached { [weak self] in
                guard let self = self else { return }
                await self.makeState()
             
            }
        }
    }
    
    private var tags = [String]()
    
    private var searchModel: SearchModel = .init(selectedTags: [], date: nil, station: nil) {
        didSet {
            self.isNeedToShowLoading = true
            self.load(page: 1, size: 10, stationID: searchModel.station?.id, tags: searchModel.selectedTags)
        }
    }
    
    
    private func load(page: Int, size: Int, stationID: Int?, tags: [String]) {
        if isNeedToShowLoading {
            self.nestedView.viewState = .loading
            isNeedToShowLoading = false
        }
        self.isLoading = true
        Task.detached(priority: .high) { [weak self] in
            guard let self = self else { return }
            do {
                let routeResponse = try await R_Route.getRoutes(page: page, size: size, stationID: stationID, tags: tags)
                let newTags = try await self.service.getTags()
                try await Task.sleep(nanoseconds: 0_300_000_000)
                await MainActor.run(body: { [weak self] in
                    self?.searchResponse = routeResponse
                    self?.tags = newTags
                })
            } catch {
                print("shiiiet")
            }
        }
    }
    
    let nestedView = R_HomeView.loadFromNib()
    
    public override func loadView() {
        self.view = nestedView
        //setupSettingsActions()
        //view.backgroundColor = Appearance.colors[.base]
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.nestedView.backgroundColor = Appearance.colors[.base]
        setOrderListener()
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.customFont(forTextStyle: .title1)
        ]
        title = "Популярное"
        load(page: 1, size: 10, stationID: nil, tags: [])
        
        NotificationCenter.default.post(name: .riverShowOrder, object: nil, userInfo: ["orderID": 74])
    }
    
    @MainActor
    private func setResponse(_ response: R_RouteResponse) async {
        self.searchResponse = response
    }
    
    @objc private func showOrder(from notification: Notification) {
        if let orderID = notification.userInfo?["orderID"] as? Int {
            print("Order: \(orderID)")
            let orderController = R_OrderDetailsController()
            self.present(orderController, animated: true) {
                orderController.orderID = orderID
            }
        }
    }
    
    private func setOrderListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(showOrder(from:)), name: .riverShowOrder, object: nil)
    }
    
    private func makeState() async {
        guard let searchResponse = searchResponse else {
            return
        }
        
        var states = [State]()
        
        if searchResponse.items.isEmpty {
            await MainActor.run { [weak self] in
                self?.nestedView.viewState = .error("Мы не смогли найти экскурсии по таким параметрам.\nПопробуйте поменять фильтры")
            }
        }
        
        let elements: [Element] = searchResponse.items.map { route in
            let firstStation = route.stations.first?.name ?? ""
            let onPay: () -> () = { [weak self] in
                self?.pushDetail(with: route.id)
            }
            let routeData = R_HomeView.ViewState.Station(
                title: route.name,
                jetty: firstStation,
                time: "\(route.time) mins",
                tickets: false,
                price: "\(route.minPrice) ₽",
                onSelect: onPay
            ).toElement()
            return routeData
        }
        let section = SectionState(header: nil, footer: nil)
        let state = State(model: section, elements: elements)
        states.append(state)
        let dateTitle: String = {
            return searchModel.date == nil ? "Дата" : searchModel.date!.toFormat("d MMMM", locale: Locales.russian)
        }()
        
        let onDateSelect = Command { [weak self] in
            
        }
        
        let dateButton = R_HomeView.ViewState.Button(
            title: dateTitle,
            isDataSetted: searchModel.date != nil,
            onSelect: onDateSelect,
            listData: nil)
        
        var listData: [R_HomeView.ViewState.ListItem]? = nil
        if #available(iOS 14.0, *) {
            listData = tags.map { routeTag in
                let onSelect = Command { [weak self] in
                    guard let self = self else { return }
                    if self.searchModel.selectedTags.contains(routeTag) {
                        self.searchModel.selectedTags.removeAll { tagToRemove in
                            tagToRemove == routeTag
                        }
                    } else {
                        self.searchModel.selectedTags.append(routeTag)
                    }
                }
                return .init(title: routeTag, onSelect: onSelect)
            }
        }
        
        let onCategorySelect = Command { [weak self] in
            
            
        }
        let categoriesTitle: String = {
            if searchModel.selectedTags.isEmpty {
                return "Категория"
            } else {
                return searchModel.selectedTags.count == 1 ? searchModel.selectedTags.first! : "Выбрано \(searchModel.selectedTags.count)"
            }
        }()
        
        let categoriesButton = R_HomeView.ViewState.Button(
            title:  categoriesTitle,
            isDataSetted: !searchModel.selectedTags.isEmpty,
            onSelect: onCategorySelect,
            listData: listData)
        
        let onStationSelect = Command { [weak self] in
            self?.openMapController()
        }
        
        let stationsButton = R_HomeView.ViewState.Button(
            title:  searchModel.station == nil ? "Причал" : searchModel.station!.name,
            isDataSetted: searchModel.station != nil,
            onSelect: onStationSelect,
            listData: nil)
        
        if searchResponse.items.count < searchResponse.totalElements {
            let onLoad = Command { [weak self] in
                guard let self = self else { return }
                self.load(page: searchResponse.page + 1, size: 10, stationID: self.searchModel.station?.id, tags: self.searchModel.selectedTags)
            }
            let loadMore = R_HomeView.ViewState.LoadMore(onLoad: isLoading ? nil : onLoad).toElement()
            states.append(.init(model: .init(header: nil, footer: nil), elements: [loadMore]))
        }
        
        
        
        await MainActor.run(body: { [weak self] in
            var clearButton: R_HomeView.ViewState.Button? = nil
            if searchModel.station != nil || !searchModel.selectedTags.isEmpty || searchModel.date != nil {
                let onSelect = Command { [weak self] in
                    guard let self = self else { return }
                    self.searchModel = .init(selectedTags: [], date: nil, station: nil)
                }
                
                clearButton = .init(title: "Сбросить фильтры", isDataSetted: true, onSelect: onSelect, listData: nil)
            }
            
            self?.nestedView.viewState = .loaded(.init(dateButton: dateButton, stationButton: stationsButton, categoriesButton: categoriesButton, clearButton: clearButton, tableState: [state]))
        })
    }
    
    private func pushDetail(with routeID: Int) {
        let detail = R_RouteDetailsController()
        navigationController?.pushViewController(detail, animated: true)
        detail.routeID = routeID
    }
    
    @MainActor
    func setState(_ state: R_HomeView.ViewState) {
        self.nestedView.viewState = state
    }
    
//    private func setupSettingsActions() {
//        guard let settingsView = nestedView.settingsView as? R_BottomSettingsView else { return }
//        settingsView.onCategoriesMenu = { [weak self] in
//            guard let self = self else { return }
//            let alert = UIAlertController(title: "😐😐😐😐", message: "", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "🕐🔨🏞", style: .default, handler: { _ in
//                alert.dismiss(animated: true)
//            }))
//            self.present(alert, animated: true, completion: nil)
//        }
//        settingsView.onTerminalsButton = { [weak self] in
//            guard let self = self else { return }
//            let controller = R_TicketsHistoryController()
//            self.navigationController?.pushViewController(controller, animated: true)
////            if Rechka.shared.isMapsAvailable {
////                self.openMapController()
////            } else {
////                self.openTerminalsTable()
////            }
//        }
//        settingsView.onPersonsMenu = { [weak self] persons in
//            guard let self = self else { return }
//            self.handle(persons)
//        }
//        settingsView.swowDatesAlert = { [weak self] in
//            guard let self = self else { return }
//            let myDatePicker: UIDatePicker = UIDatePicker()
//            myDatePicker.timeZone = .current
//            myDatePicker.datePickerMode = .date
//            myDatePicker.minimumDate = Date()
//            if #available(iOS 13.4, *) {
//                myDatePicker.preferredDatePickerStyle = .wheels
//            }
//            myDatePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200)
//            let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
//
//            alertController.view.addSubview(myDatePicker)
//            let selectAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
//                print("Selected Date: \(myDatePicker.date)")
//            })
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//            alertController.addAction(selectAction)
//            alertController.addAction(cancelAction)
//            self.present(alertController, animated: true)
//        }
//        settingsView.swowPersonsAlert = { [weak self] in
//            guard let self = self else { return }
//            let optionMenu = UIAlertController(title: nil, message: "Persons", preferredStyle: .actionSheet)
//            let partyAction = UIAlertAction(title: "Пятеро 🥳", style: .default, handler: {
//                (alert: UIAlertAction!) -> Void in
//                self.handle(5)
//            })
//            let bigFamilyAction = UIAlertAction(title: "Четверо 👨‍👩‍👧‍👦", style: .default, handler: {
//                (alert: UIAlertAction!) -> Void in
//                self.handle(4)
//            })
//            let smallFamilyAction = UIAlertAction(title: "Трое 👨‍👩‍👦", style: .default, handler: {
//                (alert: UIAlertAction!) -> Void in
//                self.handle(3)
//            })
//            let coupleAction = UIAlertAction(title: "Двое 👨‍❤️‍👨", style: .default, handler: {
//                (alert: UIAlertAction!) -> Void in
//                self.handle(2)
//            })
//            let lonelyAction = UIAlertAction(title: "Для одного 👩", style: .default, handler: {
//                (alert: UIAlertAction!) -> Void in
//                self.handle(1)
//            })
//
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
//                (alert: UIAlertAction!) -> Void in
//                print("Cancelled")
//            })
//            optionMenu.addAction(partyAction)
//            optionMenu.addAction(bigFamilyAction)
//            optionMenu.addAction(smallFamilyAction)
//            optionMenu.addAction(coupleAction)
//            optionMenu.addAction(lonelyAction)
//            optionMenu.addAction(cancelAction)
//            self.present(optionMenu, animated: true, completion: nil)
//        }
//    }
    
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
        Task {
            var points = [UIImage]()
            let client = APIClient.unauthorizedClient
            do {
                let resp1 = try await client.send(
                    .GET(
                        path: "/api/references/v1/stationsFrom",
                        query: nil
                    ), schouldPrint: true
                )
                let json1 = JSON(resp1.data)
                self.terminals = json1["data"].arrayValue.map({
                    var station = R_Station.init(data: $0)
                    station.onSelect = { [weak self] in
                        guard
                            let self = self,
                            let navigation = self.navigationController,
                            let controller = navigation.viewControllers.first
                        else { return }
                        
                        navigation.popToViewController(controller, animated: true)
                        self.searchModel.station = station
                    }
                    return station
                })
                for terminal in terminals {
                    print(terminal)
                    points.append(Appearance.makeRechkaTerminalImage(from: terminal))
                }
                controller.terminals = terminals
                controller.terminalsImages = points
            } catch {
                print("😵‍💫😵‍💫😵‍💫😵‍💫😵‍💫😵‍💫😵‍💫😵‍💫😵‍💫")
            }
        }
    }
}

extension R_PopularStationsController : RechkaMapReverceDelegate {
    
    public func onMapBackSelect() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    public func onTerminalsListSelect() {
        let controller = R_StationsListController()
        controller.terminals = terminals
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
