//
//  DetailStationController.swift
//  
//
//  Created by Слава Платонов on 11.03.2022.
//

import UIKit
import CoreTableView

class DetailStationController: UIViewController {
    
    let nestedView = DetailView(frame: UIScreen.main.bounds)
    
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
    }
    
    func makeState() {
        // summary and mapView section
        let summary = DetailView.ViewState.Summary(duration: model.duration, fromTo: model.fromTo, height: 70).toElement()
        let mapView = DetailView.ViewState.MapView(onButtonSelect: {print("open map")}, height: 175).toElement()
        let mainSection = SectionState(header: nil, footer: nil)
        let stateSummary = State(model: mainSection, elements: [summary, mapView])
        
        // Tikcets
        let tickets = DetailView.ViewState.Tickets(ticketList: model, height: 130).toElement()
        let ticketsHeader = DetailView.ViewState.TicketsHeader(ticketsCount: model.ticketsCount, height: 20)
        let ticketsSection = SectionState(header: ticketsHeader, footer: nil)
        let ticketsState = State(model: ticketsSection, elements: [tickets])
        
        // Refund section
        let refund = DetailView.ViewState.AboutRefund(height: 210).toElement()
        let refundHeader = DetailView.ViewState.RefundHeader(height: 50, isExpanded: true, onExpandTap: {
            /// reload section or insert row
        })
        let refundSectionState = SectionState(isCollapsed: refundHeader.isExpanded, header: refundHeader, footer: nil)
        let stateRefund = State(model: refundSectionState, elements: [refund])
        
        // Package section
        let package = DetailView.ViewState.AboutPackage(height: 210).toElement()
        let packageHeader = DetailView.ViewState.PackageHeader(height: 50, isExpanded: true, onExpandTap: {
            /// reload section or insert row
        })
        let packageSectionState = SectionState(isCollapsed: false, header: packageHeader, footer: nil)
        let statePackage = State(model: packageSectionState, elements: [package])
        self.nestedView.viewState = DetailView.ViewState(state: [stateSummary, ticketsState, stateRefund, statePackage], dataState: .loaded)
    }
}
