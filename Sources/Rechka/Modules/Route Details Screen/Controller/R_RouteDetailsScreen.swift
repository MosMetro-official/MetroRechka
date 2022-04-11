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
                    guard let err = error as? APIError else { throw error }
                }
            }
        }
    }
    
    
    public var route: R_Route? {
        didSet {
            createState()
        }
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
        self.nestedView.viewState = .init(state: [], dataState: .loading, onChoice: nil, onClose: nil, posterTitle: "", posterImage: nil)
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
        if let first = route.shortTrips.first {
            self.selectedTripId = first.id
        }
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
            posterImage: nil
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
                    posterImage: nil
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
        for item in sorted {
            print("=======================")
            print("KEY: \(item.key)\n")
            print("Values: \(item.value)")
        }
        
        let tripsSections: [State]  = sorted.compactMap { (key, value) in
            if let first = value.first {
                let sortedTrips: [Element] = value.sorted(by: { $0.dateStart < $1.dateStart}).map { trip in
                    let onSelect: () -> () = { [weak self] in
                        guard let self = self else { return }
                        self.selectedTripId = trip.id
                    }
                    
                    let seats: String = {
                        switch trip.freePlaceCount {
                        case 0:
                            return "Мест не осталось"
                        case 1...3:
                            return "🔥 Осталось мало мест"
                        default:
                            return "\(trip.freePlaceCount)"
                        }
                    }()
                    
                    return R_RootDetailStationView.ViewState.ShortTripInfo(
                        date: trip.dateStart.toFormat("d MMMM yyyy HH:mm", locale: Locales.russian),
                        isSelected: trip.id == self.selectedTripId ,
                        price: "\(trip.price) ₽",
                        seats: seats,
                        onSelect: onSelect
                    ).toElement()
                }
                
                let sectionTitle = first.dateStart.toFormat("d MMMM", locale: Locales.russianRussia)
                let headerData = R_RootDetailStationView.ViewState.DateHeader(title: sectionTitle)
                let sectionData = SectionState(header: headerData, footer: nil)
                return State(model: sectionData, elements: sortedTrips)
            }
            return nil
        }
        resultSections.append(contentsOf: tripsSections)
        let onChoice = Command { [weak self] in
            guard let self = self else { return }
            self.handleChoice()
        }
        let onClose = Command { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        return .init(
            state: resultSections,
            dataState: .loaded,
            onChoice: onChoice,
            onClose: onClose,
            posterTitle: model.name,
            posterImage: nil
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
