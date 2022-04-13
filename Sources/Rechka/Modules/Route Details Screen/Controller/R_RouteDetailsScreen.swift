//
//  R_RootDetailStationController.swift
//  
//
//  Created by Слава Платонов on 11.03.2022.
//

import UIKit
import CoreTableView
import CoreNetwork
import SwiftDate

internal class R_RouteDetailsController: UIViewController, RechkaMapReverceDelegate {
      
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
            Task.detached { [weak self] in
                do {
                    let route = try await R_Route.getRoute(by: routeID)
                    try await Task.sleep(nanoseconds: 0_300_000_000)
                    await self?.setRoute(route)
                } catch {
                    R_ReportService.shared.report(error: .stateError, message: error.localizedDescription, parameters: ["screen": String(describing: self)])
                    guard let err = error as? APIError else { throw error }
                    await self?.setErrorState(with: err)
                }
            }
        }
    }
    
    
    public var route: R_Route? {
        didSet {
            createState()
        }
    }
    
    @MainActor
    private func setErrorState(with error: APIError) {
        
        var title = "Возникла ошибка при загрузке"
        if case .genericError(let message) = error {
            title = message
        }
        
        let finalTitle = title
        
        let onSelect = Command { [weak self] in
            guard let self = self, let _routeId = self.routeID else { return }
            self.routeID = _routeId
            
        }
        let err = R_OrderDetailsView.ViewState.Error(
            image: UIImage(systemName: "xmark.octagon") ?? UIImage(),
            title: finalTitle,
            action: onSelect,
            buttonTitle: "Загрузить еще раз",
            height: UIScreen.main.bounds.height / 2)
            .toElement()
        let state = State(model: .init(header: nil, footer: nil), elements: [err])
        self.nestedView.viewState = .init(state: [state],
                                          dataState: .error,
                                          onChoice: nil,
                                          onClose: self.nestedView.viewState.onClose,
                                          posterTitle: self.nestedView.viewState.posterTitle,
                                          posterImageURL: self.nestedView.viewState.posterImageURL)
    }
    
    private var isTextCollapsed = true {
        didSet {
            if let route = route {
                Task.detached { [weak self] in
                    guard let self = self else { return }
                    let state = await self.makeState(with: route)
                    await self.setState(state)
                }
            }
        }
    }
    
    private var isNeedToCollapseText = true
    
    private func createState() {
        if let route = route {
            Task.detached { [weak self] in
                guard let self = self else { return }
                let state = await self.makeState(with: route)
                await self.setState(state)
            }
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
    
    @MainActor
    private func setRoute(_ route: R_Route) {
//        if let first = route.shortTrips.first {
//            self.selectedTripId = first.id
//        }
        self.route = route
    }
    
    @MainActor
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
        Task.detached { [weak self] in
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
                await self?.setState(loadedState)
                await self?.openBuyTicketsController(with: trip)
            } catch {
                
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
    
    func makeState(with model: R_Route) async -> R_RootDetailStationView.ViewState {
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
                        text: text,
                        onMore: isTextCollapsed ? onMore : nil,
                        height: isTextCollapsed ? 80 + 24 :  size.height + 24)
                        .toElement()
                    main.append(summary)
                    
                    
                } else {
                    let summary = R_RootDetailStationView.ViewState.Summary(
                        text: text,
                        onMore: nil,
                        height: size.height + 24)
                        .toElement()
                    main.append(summary)
                }
                
                
            }
            
            
        }
        
        
        if Rechka.shared.isMapsRoutesAvailable {
            let mapView = R_RootDetailStationView.ViewState.MapView(
                onButtonSelect: { [weak self] in
                    guard let self = self else { return }
                    self.showRouteOnMap()
                }
            ).toElement()
            main.append(mapView)
        }
        let infoSection = SectionState(header: nil, footer: nil)
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
                    day: dayTitle,
                    items: tripsOnThisDay,
                    shouldScrollToInitial: shouldScrollToInitial)
                    .toElement()
            }
            return nil
        }

        let tripsHeaderData = R_RootDetailStationView.ViewState.DateHeader(title: "Когда поедем?")
        let tripsSection = SectionState(header: tripsHeaderData, footer: nil)
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
        return .init(
            state: resultSections,
            dataState: .loaded,
            onChoice: self.selectedTripId == nil ? nil : onChoice,
            onClose: onClose,
            posterTitle: model.name,
            posterImageURL: imageURL
        )
    }
    
    private func showRouteOnMap() {
        self.delegate = Rechka.shared.delegate
        let controller = delegate?.getRechkaMapController()
        guard
            let controller = controller,
            let navigation = navigationController
        else { fatalError() }
        controller.delegate = self
        controller.shouldShowTerminalsButton = false
        navigation.pushViewController(controller, animated: true)
    }
}

extension R_RouteDetailsController {
        
    @MainActor
    private func openBuyTicketsController(with model: R_Trip) {
//        guard let needPersonalData = model.personalDataRequired else { return }
//        if needPersonalData {
//            let bookingWithPerson = R_BookingWithPersonController()
//            bookingWithPerson.model = model
//            navigationController?.pushViewController(bookingWithPerson, animated: true)
//        } else {
//            let bookingWithoutPerson = R_BookingWithoutPersonController()
//            bookingWithoutPerson.model = model
//            navigationController?.pushViewController(bookingWithoutPerson, animated: true)
//        }
        let bookingWithPerson = R_BookingWithPersonController()
        bookingWithPerson.model = model
        navigationController?.pushViewController(bookingWithPerson, animated: true)
    }
}
