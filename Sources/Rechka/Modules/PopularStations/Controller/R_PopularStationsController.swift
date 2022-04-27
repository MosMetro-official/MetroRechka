//
//  R_PopularStationsController.swift
//  
//
//  Created by Слава Платонов on 06.03.2022.
//

import UIKit
import CoreTableView
import MMCoreNetwork
import SwiftDate


internal final class R_PopularStationsController : UIViewController {
    
    weak var delegate : RechkaMapDelegate?
    
    
    
    struct SearchModel {
        var selectedTags: [String]
        var date: Date?
        var station: R_Station?
    }
    
    private let service = R_Service()
    
    private var searchResponse: R_RouteResponse? {
        didSet {
            guard let searchResponse = searchResponse else { return }
            self.routes.append(contentsOf: searchResponse.items)
        }
    }
    
    
    private var routes: [R_Route] = [] {
        didSet {
            if isNeedToUpdateState {
                self.dataModel = .loaded(routes)
            }
        }
    }
    
    
    var dataModel: DataModel = .loading {
        didSet {
            self.makeState()
        }
    }
    
    enum DataModel {
        case loading
        case loadingNewPage([R_Route])
        case loaded([R_Route])
    }
    
    private var isNeedToUpdateState = true
    
    private var tags = [String]()
    
    private var searchModel: SearchModel = .init(selectedTags: [], date: nil, station: nil) {
        didSet {
            self.dataModel = .loading
            self.isNeedToUpdateState = false
            self.routes = []
            self.isNeedToUpdateState = true
            self.load(page: 0, size: 10, stationID: searchModel.station?.id, tags: searchModel.selectedTags, date: searchModel.date)
        }
    }
    
    
    private func load(page: Int, size: Int, stationID: Int?, tags: [String], date: Date?) {
       
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        R_Route.getRoutes(page: page, size: size, stationID: stationID, date: date, tags: tags) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let routesResponse):
                self.searchResponse = routesResponse
                dispatchGroup.leave()
            case .failure:
                DispatchQueue.main.async {
                    let onSelect: () -> Void = { [weak self] in
                        guard let self = self else { return }
                        self.load(page: 0, size: 10, stationID: nil, tags: [], date: nil)
                    }
                    
                    let buttonData = R_Toast.Configuration.Button(image: UIImage(systemName: "arrow.triangle.2.circlepath"), title: nil, onSelect: onSelect)
                    let errorConfig = R_Toast.Configuration.defaultError(text: "Произошла ошибка при загрузке", subtitle: nil, buttonType: .imageButton(buttonData))
                    self.nestedView.viewState = .error(errorConfig)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.enter()
        service.getTags { result in
            switch result {
            case .success(let tags):
                self.tags = tags
                dispatchGroup.leave()
            case .failure(let err):
                print(err)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            print("All tasks finished")
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
       
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        navigationController?.navigationBar.topItem?.rightBarButtonItem = barButtonItem
        title = "Популярное"
        self.dataModel = .loading
        load(page: 0, size: 10, stationID: nil, tags: [], date: nil)
    }
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
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
    
    private func createState(for routes: [R_Route]) -> State {
        let elements: [Element] = routes.map { route in
            let firstStation = route.stations.first?.name ?? ""

            
            var imageURL: String? = nil
            if let routeFirstGallery = route.galleries.first, let firstURL = routeFirstGallery.urls.first {
                imageURL = firstURL
            } else {
                if let firstStation = route.stations.first, let firstURL = firstStation.galleries.first?.urls.first {
                    imageURL = firstURL
                }
            }
            let onSelect = Command { [weak self] in
                self?.pushDetail(with: route.id)
            }
            
            let routeData = R_HomeView.ViewState.Route(
                title: route.name,
                time: "\(route.time) мин.",
                station: firstStation,
                priceButtonTitle: "От \(route.minPrice) ₽",
                imageURL: imageURL,
                onItemSelect: onSelect)
                .toElement()
            return routeData
        }
        let section = SectionState(header: nil, footer: nil)
        let routesState = State(model: section, elements: elements)
        return routesState
    }
    
    private func stateForLoaded(tableState: [State]) -> R_HomeView.ViewState {
        
        
        let dateTitle: String = {
            let moscow  = Region(calendar: Calendars.gregorian, zone: Zones.europeMoscow, locale: Locales.russian)
            
            return searchModel.date == nil ? "Дата" : searchModel.date!.convertTo(region: moscow).toFormat("d MMMM", locale: Locales.russian)
        }()
        
        let onDateSelect = Command { [weak self] in
            self?.showDatePicker()
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
                let isSelected = self.searchModel.selectedTags.contains(routeTag)
                
                return .init(title: routeTag.capitalizingFirstLetter(), isSelected: isSelected, onSelect: onSelect)
            }
        }
        
        let onCategorySelect = Command { [weak self] in
            guard let self = self else { return }
            if #available(iOS 14.0, *) { } else {
                let alert = UIAlertController(title: "Категории", message: nil, preferredStyle: .actionSheet)
                var actions: [UIAlertAction] = self.tags.map { routeTag in
                    let isSelected = self.searchModel.selectedTags.contains(routeTag)
                    let action =  UIAlertAction(title: routeTag.capitalizingFirstLetter(), style: .default) { [weak self] action in
                        guard let self = self else { return }
                        if self.searchModel.selectedTags.contains(routeTag) {
                            self.searchModel.selectedTags.removeAll { tagToRemove in
                                tagToRemove == routeTag
                            }
                        } else {
                            self.searchModel.selectedTags.append(routeTag)
                        }
                    }
                    action.setValue(isSelected ? UIColor.systemBlue : UIColor.label, forKey: "titleTextColor")
                    return action
                }
                
                actions.append(.init(title: "Закрыть", style: .cancel, handler: { _ in
                    alert.dismiss(animated: true, completion: nil)
                }))
                actions.forEach {
                    alert.addAction($0)
                }
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
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
        
        
        var clearButton: R_HomeView.ViewState.Button? = nil
        if searchModel.station != nil || !searchModel.selectedTags.isEmpty || searchModel.date != nil {
            let onSelect = Command { [weak self] in
                guard let self = self else { return }
                //self.routes = []
                self.searchModel = .init(selectedTags: [], date: nil, station: nil)
            }
            
            clearButton = .init(title: "Сбросить фильтры", isDataSetted: true, onSelect: onSelect, listData: nil)
        }
        let state: R_HomeView.ViewState = .loaded(.init(dateButton: dateButton, stationButton: stationsButton, categoriesButton: categoriesButton, clearButton: clearButton, tableState: tableState))
        return state
        
    }
    
    
    private func makeState()  {
        guard let searchResponse = searchResponse else {
            return
        }
        var states = [State]()
        
        switch dataModel {
        case .loading:
            self.nestedView.viewState = .loading
        case .loadingNewPage(let routes):
            let routesState = createState(for: routes)
            states.append(routesState)
            let loadMore = R_HomeView.ViewState.LoadMore(onLoad: nil).toElement()
            states.append(.init(model: .init(header: nil, footer: nil), elements: [loadMore]))
            
            let state = stateForLoaded(tableState: states)
            DispatchQueue.main.async { [weak self] in
                self?.nestedView.viewState = state
            }
            
        case .loaded(let routes):
            
            
            if routes.isEmpty {
                let clearAction = Command { [weak self] in
                    self?.searchModel = .init(selectedTags: [], date: nil, station: nil)
                }
                
                let notFoundErr = R_HomeView.ViewState.Error(
                    image: UIImage(systemName: "magnifyingglass") ?? UIImage(),
                    title: "Мы не нашли экскурсий с такими параметрами",
                    action: clearAction,
                    buttonTitle: "Сбросить фильтры",
                    height: UIScreen.main.bounds.height / 2)
                    .toElement()
                let section = SectionState(header: nil, footer: nil)
                let errorState = State(model: section, elements: [notFoundErr])
                states.append(errorState)
            } else {
                let routesState = createState(for: routes)
                states.append(routesState)
                if routes.count < searchResponse.totalElements {
                    let onLoad = Command { [weak self] in
                        guard let self = self else { return }
                        self.dataModel = .loadingNewPage(routes)
                        self.load(page: searchResponse.page + 1, size: 10, stationID: self.searchModel.station?.id, tags: self.searchModel.selectedTags, date: self.searchModel.date)
                    }
                    let loadMore = R_HomeView.ViewState.LoadMore(onLoad: onLoad).toElement()
                    states.append(.init(model: .init(header: nil, footer: nil), elements: [loadMore]))
                }
            }
            
            
            let state = stateForLoaded(tableState: states)
            DispatchQueue.main.async { [weak self] in
                self?.nestedView.viewState = state
            }
        }
    }
    
    private func pushDetail(with routeID: Int) {
        let detail = R_RouteDetailsController()
        navigationController?.pushViewController(detail, animated: true)
        detail.routeID = routeID
    }
    
    
    func setState(_ state: R_HomeView.ViewState) {
        self.nestedView.viewState = state
    }
    
    private func showDatePicker() {
        let myDatePicker: UIDatePicker = UIDatePicker()
        myDatePicker.timeZone = .current
        myDatePicker.datePickerMode = .date
        myDatePicker.minimumDate = Date()
        if let selectedDate = searchModel.date {
            myDatePicker.setDate(selectedDate, animated: false)
        }
        
        myDatePicker.locale = Locale(identifier: "ru_RU")
        if #available(iOS 13.4, *) {
            myDatePicker.preferredDatePickerStyle = .wheels
        }
        myDatePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200)
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        
        alertController.view.addSubview(myDatePicker)
        let selectAction = UIAlertAction(title: "Выбрать", style: .default, handler: { [weak self] _ in
            self?.searchModel.date = myDatePicker.date
        })
        var clearAction: UIAlertAction? = nil
        if let _ = searchModel.date {
            clearAction = UIAlertAction(title: "Сбросить дату", style: .destructive, handler: { [weak self] _ in
                self?.searchModel.date = nil
            })
        }
        
        let cancelAction = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        alertController.addAction(selectAction)
        if let clearAction = clearAction {
            alertController.addAction(clearAction)
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    private func openMapController() {
        guard
            let controller = delegate?.rechkaStationsController(),
            let navigation = navigationController
        else { fatalError() }
        navigation.pushViewController(controller, animated: true)
        controller.onStationSelect = { [weak self] station in
            guard let self = self else { return }
            self.searchModel.station = station
        }
    }
//    private func openMapController() {
//        let vc = R_TicketsHistoryController()
//        navigationController?.pushViewController(vc, animated: true)
//    }
}


