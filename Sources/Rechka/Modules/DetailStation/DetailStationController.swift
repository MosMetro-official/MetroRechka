//
//  DetailStationController.swift
//  
//
//  Created by Слава Платонов on 11.03.2022.
//

import UIKit
import CoreTableView

class DetailStationController: UIViewController, RechkaMapReverceDelegate {
    
    func onMapBackSelect() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func onTerminalsListSelect() {
        
    }
    
    
    var nestedView = DetailView(frame: UIScreen.main.bounds)
    
    var delegate : RechkaMapDelegate? = nil
    
    var showRefundRow = false {
        didSet {
            DispatchQueue.main.async {
                self.makeState()
            }
        }
    }
    
    var showBaggageRow = false {
        didSet {
            DispatchQueue.main.async {
                self.makeState()
            }
        }
    }
    
    var model: FakeModel!
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        nestedView.posterHeaderView?.configurePosterHeader(with: model)
        makeState()
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
    
    private func setupNestedViewActions() {
        nestedView.onClose = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        nestedView.onChoice = { [weak self] in
            guard let self = self else { return }
            self.goToBuyTicketsWithPersonData(with: self.model)
        }
    }
    
    func makeState() {
        var main = [Element]()
        let summary = DetailView.ViewState.Summary(
            duration: model.duration,
            fromTo: model.fromTo,
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
        let mainSection = SectionState(header: nil, footer: nil)
        let stateSummary = State(model: mainSection, elements: main)
        
        // Tikcets
        let tickets = DetailView.ViewState.Tickets(
            ticketList: model,
            height: 130
        ).toElement()
        let ticketsHeader = DetailView.ViewState.TicketsHeader(
            ticketsCount: model.ticketsCount,
            height: 20
        )
        let ticketsSection = SectionState(header: ticketsHeader, footer: nil)
        let ticketsState = State(model: ticketsSection, elements: [tickets])
        
        // Refund section
        let refund = DetailView.ViewState.AboutRefund(height: 210).toElement()
        
        let refundHeader = DetailView.ViewState.RefundHeader(height: 50, isExpanded: true, onExpandTap: {
            self.showRefundRow.toggle()
        })
        var refundElements = [Element]()
        if showRefundRow { refundElements.append(refund) }
        let refundSectionState = SectionState(isCollapsed: false, header: refundHeader, footer: nil)
        let stateRefund = State(model: refundSectionState, elements: refundElements)
        
        // Package section
        let package = DetailView.ViewState.AboutPackage(height: 210).toElement()
        let packageHeader = DetailView.ViewState.PackageHeader(
            height: 50,
            isExpanded: true,
            onExpandTap: {
            self.showBaggageRow.toggle()
        })
        var packagelements = [Element]()
        if showBaggageRow { packagelements.append(package) }
        let packageSectionState = SectionState(isCollapsed: false, header: packageHeader, footer: nil)
        let statePackage = State(model: packageSectionState, elements: packagelements)
        self.nestedView.viewState = DetailView.ViewState(state: [stateSummary, ticketsState, stateRefund, statePackage], dataState: .loaded)
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
    private func goToBuyTicketsWithPersonData(with model: FakeModel) {
        // if model.isPersonalDataRequired { push with personData } else { push without personData }
        let bookingWithPerson = PersonBookingController()
        bookingWithPerson.model = model
        navigationController?.pushViewController(bookingWithPerson, animated: true)
    }
}
