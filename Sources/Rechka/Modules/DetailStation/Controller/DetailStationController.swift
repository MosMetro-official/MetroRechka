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
        self.route = route
    }
    
    @MainActor
    private func setState(_ state: DetailView.ViewState) {
        self.nestedView.viewState = state
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
        
        if Rechka.isMapsRoutesAvailable {
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
            let date = Calendar(identifier: .gregorian).dateComponents([.day, .month, .year], from: (element.dateStart))
           // let date = Calendar.current.dateComponents([.day, .month, .year], from: (element.dateStart))
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
                    return DetailView.ViewState.ShortTripInfo(
                        date: trip.dateStart.toFormat("d MMMM yyyy HH:mm", locale: Locales.russian),
                        isSelected: trip.id == self.selectedTripId ,
                        price: "\(trip.price) ₽",
                        seats: "\(trip.freePlaceCount)",
                        onSelect: {})
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
        
    
        return .init(state: resultSections, dataState: .loaded)
    }
    
    private func showRouteOnMap() {
        self.delegate = Rechka.delegate
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
    private func openBuyTicketsController(with model: FakeModel) {
        if model.isPersonalDataRequired {
            let bookingWithPerson = PersonBookingController()
            bookingWithPerson.model = model
            navigationController?.pushViewController(bookingWithPerson, animated: true)
        } else {
            let bookingWithoutPerson = WithoutPersonBookingController()
            bookingWithoutPerson.model = model
            navigationController?.pushViewController(bookingWithoutPerson, animated: true)
        }
    }
}
