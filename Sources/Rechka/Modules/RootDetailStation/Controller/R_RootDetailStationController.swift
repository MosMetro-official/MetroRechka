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

internal class R_RootDetailStationController: UIViewController, RechkaMapReverceDelegate {
      
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
    
    func makeState(with model: R_Route) async -> R_RootDetailStationView.ViewState {
        var resultSections = [State]()
        var main = [Element]()
        let summary = R_RootDetailStationView.ViewState.Summary(
            duration: "dasdadsa",
            fromTo: "test1"
        ).toElement()
        main.append(summary)
        
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

extension R_RootDetailStationController {
        
    @MainActor
    private func openBuyTicketsController(with model: R_Trip) {
        guard let needPersonalData = model.personalDataRequired else { return }
        if needPersonalData {
//            let bookingWithPerson = R_BookingWithPersonController()
//            bookingWithPerson.model = model
//            navigationController?.pushViewController(bookingWithPerson, animated: true)
        } else {
            let bookingWithoutPerson = R_BookingWithoutPersonController()
            bookingWithoutPerson.model = model
            navigationController?.pushViewController(bookingWithoutPerson, animated: true)
        }
    }
}
