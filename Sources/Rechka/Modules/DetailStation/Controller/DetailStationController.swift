//
//  DetailStationController.swift
//  
//
//  Created by Слава Платонов on 11.03.2022.
//

import UIKit
import CoreTableView
import CoreNetwork
import SwiftDate

class DetailStationController: UIViewController, RechkaMapReverceDelegate {
    
   
   
    
    func onMapBackSelect() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func onTerminalsListSelect() { }
    
    var nestedView = DetailView(frame: UIScreen.main.bounds)
    
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
                    let route = try await RiverRoute.getRoute(by: routeID)
                    try await Task.sleep(nanoseconds: 0_300_000_000)
                    await self?.setRoute(route)
                } catch {
                    guard let err = error as? APIError else { throw error }
                    
                }
                
            }
        }
    }
    
    
    public var route: RiverRoute? {
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
        //nestedView.posterHeaderView?.configurePosterHeader(with: model)
        setupNestedViewActions()
        self.nestedView.viewState = .init(state: [], dataState: .loading, onChoice: nil)
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
    private func setRoute(_ route: RiverRoute) {
        if let first = route.shortTrips.first {
            self.selectedTripId = first.id
        }
        self.route = route
    }
    
    @MainActor
    private func setState(_ state: DetailView.ViewState) {
        self.nestedView.viewState = state
    }
    
    
    private func handleChoice() {
        guard let selectedTripId = selectedTripId else {
            return
        }
        let loadingState = DetailView.ViewState(state: self.nestedView.viewState.state,
                                                dataState: .loading,
                                                onChoice: self.nestedView.viewState.onChoice)
        self.nestedView.viewState = loadingState
        Task.detached { [weak self] in
            do {
                let trip = try await RiverTrip.get(by: selectedTripId)
                let loadedState = DetailView.ViewState(state: loadingState.state,
                                                       dataState: .loaded,
                                                       onChoice: loadingState.onChoice)
                await self?.setState(loadedState)
                await self?.openBuyTicketsController(with: trip)
                
            } catch {
                
            }
            
        }
    }
    
    
    private func setupNestedViewActions() {
        nestedView.onClose = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        nestedView.onChoice = { [weak self] in
            guard let self = self else { return }
            //self.goToBuyTicketsWithPersonData(with: self.model)
        }
    }
    
    func makeState(with model: RiverRoute) async -> DetailView.ViewState {
        var resultSections = [State]()
        var main = [Element]()
        let summary = DetailView.ViewState.Summary(
            duration: "dasdadsa",
            fromTo: "test1",
            height: 70
        ).toElement()
        main.append(summary)
        
        if Rechka.shared.isMapsRoutesAvailable {
            let mapView = DetailView.ViewState.MapView(
                onButtonSelect: { [weak self] in
                    guard let self = self else { return }
                    self.showRouteOnMap()
                },
                height: 175
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
                    
                    return DetailView.ViewState.ShortTripInfo(
                        date: trip.dateStart.toFormat("d MMMM yyyy HH:mm", locale: Locales.russian),
                        isSelected: trip.id == self.selectedTripId ,
                        price: "\(trip.price) ₽",
                        seats: seats,
                        onSelect: onSelect)
                        .toElement()
                    
                }
                let sectionTitle = first.dateStart.toFormat("d MMMM", locale: Locales.russianRussia)
                let headerData = DetailView.ViewState.DateHeader(title: sectionTitle)
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
    
        return .init(state: resultSections, dataState: .loaded, onChoice: onChoice)
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

extension DetailStationController {
    
    
    @MainActor
    private func openBuyTicketsController(with model: RiverTrip) {
        let bookingWithoutPerson = WithoutPersonBookingController()
        bookingWithoutPerson.model = model
        navigationController?.pushViewController(bookingWithoutPerson, animated: true)
        
        
//        if model.isPersonalDataRequired {
//            let bookingWithPerson = PersonBookingController()
//            bookingWithPerson.model = model
//            navigationController?.pushViewController(bookingWithPerson, animated: true)
//        } else {
//            let bookingWithoutPerson = WithoutPersonBookingController()
//            //bookingWithoutPerson.model = model
//            navigationController?.pushViewController(bookingWithoutPerson, animated: true)
//        }
    }
}
