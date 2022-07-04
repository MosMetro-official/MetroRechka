//
//  R_RootDetailStationController.swift
//  
//
//  Created by Слава Платонов on 11.03.2022.
//

import UIKit
import CoreTableView
import MMCoreNetworkAsync
import SwiftDate

internal class R_RouteDetailsController: UIViewController {
    
    func onMapBackSelect() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func onTerminalsListSelect() { }
    
    var nestedView = R_RootDetailStationView(frame: UIScreen.main.bounds)
    
    var delegate : RechkaMapDelegate? = nil
    
    private var selectedTripId: Int? {
        didSet {
            createState()
        }
    }
    
    private var isFirstLoad = true
    
    public var routeID: Int? {
        didSet {
            guard let routeID = routeID else {
                return
            }
            Task {
                do {
                    let client = APIClient.unauthorizedClient
                    let route: R_BaseResponse<R_Route> = try await client.send(.GET(path: "/api/routes/v1/\(routeID)")).value
                    self.route = route.data
                } catch {
                    if let err = error as? APIError {
                        setErrorState(with: err)
                    }
                    setErrorState(with: .badRequest)
                }
                
            }
        }
    }
    
    
    public var route: R_Route? {
        didSet {
            createState()
        }
    }
    
    
    private func setErrorState(with error: APIError) {
        var title = "Возникла ошибка при загрузке"
        if case .genericError(let message) = error {
            title = message
        }
        
        let finalTitle = title
        
        let onSelect: () -> Void = { [weak self] in
            guard let self = self, let _routeId = self.routeID else { return }
            self.routeID = _routeId
        }
        
        let currentState = self.nestedView.viewState
        let buttonType = R_Toast.Configuration.Button(
            image: UIImage(systemName: "arrow.triangle.2.circlepath"),
            title: nil,
            onSelect: onSelect)
        
        let config = R_Toast.Configuration.defaultError(text: finalTitle, subtitle: nil, buttonType: .imageButton(buttonType))
        
        let newState = R_RootDetailStationView.ViewState(
            state: currentState.state,
            dataState: .error(config),
            onChoice: currentState.onChoice,
            onClose: currentState.onClose,
            posterTitle: currentState.posterTitle,
            posterImageURL: currentState.posterImageURL)
        self.nestedView.viewState = newState

    }
    
    private var isTextCollapsed = true {
        didSet {
            if let route = route {
                self.makeState(with: route)
            }
        }
    }
    
    private var isNeedToCollapseText = true
    
    private func createState() {
        if let route = route {
            self.makeState(with: route)
        }
    }
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.nestedView.viewState = .init(state: [], dataState: .loading, onChoice: nil, onClose: nil, posterTitle: "", posterImageURL: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    private func setRoute(_ route: R_Route) {
        //        if let first = route.shortTrips.first {
        //            self.selectedTripId = first.id
        //        }
        self.route = route
    }
    
    
    private func setState(_ state: R_RootDetailStationView.ViewState) {
        self.nestedView.viewState = state
    }
    
    private func handleChoice() {
        guard let selectedTripId = selectedTripId else {
            return
        }
        let loadingState = R_RootDetailStationView.ViewState(
            state: self.nestedView.viewState.state,
            dataState: .loading,
            onChoice: self.nestedView.viewState.onChoice,
            onClose: self.nestedView.viewState.onClose,
            posterTitle: "",
            posterImageURL: self.nestedView.viewState.posterImageURL
        )
        self.nestedView.viewState = loadingState
        Task {
            do {
                let trip = try await R_Trip.get(by: selectedTripId)
                let loadedState = R_RootDetailStationView.ViewState(
                    state: loadingState.state,
                    dataState: .loaded,
                    onChoice: loadingState.onChoice,
                    onClose: loadingState.onClose,
                    posterTitle: "",
                    posterImageURL: loadingState.posterImageURL
                )
                self.setState(loadedState)
                self.openBuyTicketsController(with: trip)
            } catch {
                let err: APIError = (error as? APIError) != nil ? (error as! APIError) : .badRequest
                let currentState = self.nestedView.viewState
                let onSelect: () -> Void = { [weak self] in
                    self?.handleChoice()
                }
                let buttonType = R_Toast.Configuration.Button(
                    image: UIImage(systemName: "arrow.triangle.2.circlepath"),
                    title: nil,
                    onSelect: onSelect)
                
                let config = R_Toast.Configuration.defaultError(text: err.localizedDescription, subtitle: nil, buttonType: .imageButton(buttonType))
                
                let newState = R_RootDetailStationView.ViewState(
                    state: currentState.state,
                    dataState: .error(config),
                    onChoice: currentState.onChoice,
                    onClose: currentState.onClose,
                    posterTitle: currentState.posterTitle,
                    posterImageURL: currentState.posterImageURL)
                self.nestedView.viewState = newState
            }
        }
        

    }
    
    func prepareText(for description: String) -> NSMutableAttributedString? {
        let attributedString = NSMutableAttributedString(string: description)
        let range = NSMakeRange(0, attributedString.string.count - 1)
        if let font = Appearance.customFonts[.body] {
            attributedString.addAttributes([NSAttributedString.Key.font: font], range: range)
        }
        attributedString.addAttributes([NSAttributedString.Key.kern: -0.17], range: range)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = 4
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: range)
        return attributedString
        //        if size.height > 60 {
        //            // надо урезать размер и добавить кнопку еще
        //            let moreStr = NSAttributedString(string: "...еще", attributes: [NSAttributedString.Key.font: Appearance.customFonts[.body], NSAttributedString.Key.foregroundColor: UIColor.systemBlue])
        //            attributedString.append(moreStr)
        //
        //
        //
        //        } else {
        //
        //        }
        //        return attributedString
        
    }
    
    func makeState(with model: R_Route) {
        var resultSections = [State]()
        var main = [Element]()
        if let gallery = model.galleries.first, let desc = gallery.galleryDescription {
            if let text = self.prepareText(for: desc) {
                let maxWidth = UIScreen.main.bounds.size.width - 40
                let size = text.boundingRect(with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
                self.isNeedToCollapseText = size.height > 80
                
                if isNeedToCollapseText {
                    let onMore = Command { [weak self] in
                        self?.isTextCollapsed = false
                    }
                    
                    let summary = R_RootDetailStationView.ViewState.Summary(
                        id: "summary",
                        text: text,
                        onMore: isTextCollapsed ? onMore : nil,
                        height: isTextCollapsed ? 80 + 24 :  size.height + 24)
                        .toElement()
                    main.append(summary)
                    
                    
                } else {
                    let summary = R_RootDetailStationView.ViewState.Summary(
                        id: "summary",
                        text: text,
                        onMore: nil,
                        height: size.height + 24)
                        .toElement()
                    main.append(summary)
                }
                
                
            }
            
            
        }
        
        
        if Rechka.shared.isMapsRoutesAvailable && !model.polyline.isEmpty {
            let mapView = R_RootDetailStationView.ViewState.MapView(
                id: "mapview",
                onButtonSelect: { [weak self] in
                    guard let self = self else { return }
                    self.showRouteOnMap()
                }
            ).toElement()
            main.append(mapView)
        }
        let infoSection = SectionState(id: "info", header: nil, footer: nil)
        let infoSectionState = State(model: infoSection, elements: main)
        let dict = Dictionary.init(grouping: model.shortTrips, by: { element -> DateComponents in
            //let date = Calendar(identifier: .gregorian).dateComponents([.day, .month, .year], from: (element.dateStart))
            
            let date = Calendar.current.dateComponents([.day, .month, .year], from: (element.dateStart.dateAt(.startOfDay).date))
            return date
        })
        resultSections.append(infoSectionState)
        
        let sorted = dict.sorted(by: { $0.key < $1.key })
        
        R_ReportService.shared.report(event: "river.sortedDict", parameters: ["keys": dict.keys.map { $0.description }, "values": dict.values.map { $0.count } ])
        
        for item in sorted {
            print("=======================")
            print("KEY: \(item.key)\n")
            print("Values: \(item.value)")
        }
        
        let tripsTest: [Element] = sorted.compactMap { (key, value) in
            if let first = value.first {
                
                // creating trips on this day
                let tripsOnThisDay: [_R_DateCollectionCell] = value.sorted(by: { $0.dateStart < $1.dateStart}).map { trip in
                    let onSelect = Command {  [weak self] in
                        guard let self = self else { return }
                        self.selectedTripId = trip.id
                    }
                    
                    let isSelected = trip.id == self.selectedTripId
                    let primaryText = Appearance.colors[.textPrimary] ?? .label
                    let tint = Appearance.colors[.buttonSecondary] ?? .label
                    let invertedText = Appearance.colors[.textInverted] ?? .systemBackground
                    
                    return R_RootDetailStationView.ViewState.TripTime(
                        time: trip.dateStart.toFormat("HH:mm", locale: Locales.russian),
                        textColor: isSelected ? invertedText : primaryText,
                        bgColor: isSelected ? tint : UIColor.clear,
                        borderColor: isSelected ? tint : primaryText,
                        onSelect: onSelect)
                }
                let shouldScrollToInitial = value.contains(where: {  $0.id == self.selectedTripId })
                let dayTitle = first.dateStart.toFormat("d MMM", locale: Locales.russianRussia)
                return R_RootDetailStationView.ViewState.Trips(
                    id: "\(dayTitle)",
                    day: dayTitle,
                    items: tripsOnThisDay,
                    shouldScrollToInitial: shouldScrollToInitial)
                .toElement()
            }
            return nil
        }
        
        let tripsHeaderData = R_RootDetailStationView.ViewState.DateHeader(id: "header", title: "Когда поедем?")
        let tripsSection = SectionState(id: "header", header: tripsHeaderData, footer: nil)
        resultSections.append(.init(model: tripsSection, elements: tripsTest))
        let onChoice = Command { [weak self] in
            guard let self = self else { return }
            self.handleChoice()
        }
        let onClose = Command { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        var imageURL: String? = nil
        if let routeFirstGallery = model.galleries.first, let firstURL = routeFirstGallery.urls.first {
            imageURL = firstURL
        } else {
            if let firstStation = model.stations.first, let firstURL = firstStation.galleries.first?.urls.first {
                imageURL = firstURL
            }
        }
        R_ReportService.shared.report(event: "river.detailscreen.stateCreated", parameters: ["resultSections": "\(resultSections.count)", "modelTripsCount": model.shortTrips.count])
        let state = R_RootDetailStationView.ViewState(
            state: resultSections,
            dataState: .loaded,
            onChoice: self.selectedTripId == nil ? nil : onChoice,
            onClose: onClose,
            posterTitle: model.name,
            posterImageURL: imageURL
        )
        self.nestedView.viewState = state
    }
    
    private func showRouteOnMap() {
        self.delegate = Rechka.shared.delegate
        guard
            let route = route,
            let controller = delegate?.rechkaRouteController(with: route),
            let navigation = navigationController
        else { fatalError() }
        controller.route = route
        navigation.pushViewController(controller, animated: true)
    }
}

extension R_RouteDetailsController {
    
    
    private func openBuyTicketsController(with model: R_Trip) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let needPersonalData = model.personalDataRequired else { return }
            if needPersonalData {
                let bookingWithPerson = R_BookingWithPersonController()
                bookingWithPerson.model = model
                self.navigationController?.pushViewController(bookingWithPerson, animated: true)
            } else {
                let bookingWithoutPerson = R_BookingWithoutPersonController()
                bookingWithoutPerson.model = model
                self.navigationController?.pushViewController(bookingWithoutPerson, animated: true)
            }
        }
    }
}
