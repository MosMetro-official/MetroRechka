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
    
    var model: FakeModel! {
        didSet {
            print(model.title)
        }
    }
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        nestedView.posterHeaderView?.configurePosterHeader(with: model.title)
        makeState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
    }
    
    func makeState() {
        // summary and mapView section
        let summary = DetailView.ViewState.Summary(duration: model.duration, fromTo: model.fromTo, height: 70).toElement()
        let mapView = DetailView.ViewState.MapView(onButtonSelect: {print("open map")}, height: 175).toElement()
        let mainSection = SectionState(header: nil, footer: nil)
        let stateSummary = State(model: mainSection, elements: [summary, mapView])
        
        // Expanded section
        let refund = DetailView.ViewState.AboutRefund(height: 150).toElement()
        let refundHeader = DetailView.ViewState.RefundHeader(height: 50, isExpanded: true, onSelect: {
            /// reload section
        })
        let refundSectionState = SectionState(isCollapsed: refundHeader.isExpanded, header: refundHeader, footer: nil)
        let stateRefund = State(model: refundSectionState, elements: [refund])
        let packageHeader = DetailView.ViewState.PackageHeader(height: 50, isExpanded: true, onSelect: {
            /// reload section
        })
        let packageSectionState = SectionState(isCollapsed: packageHeader.isExpanded, header: packageHeader, footer: nil)
        let package = DetailView.ViewState.AboutPackage(height: 150).toElement()
        let statePackage = State(model: packageSectionState, elements: [package])
        self.nestedView.viewState = DetailView.ViewState(state: [stateSummary, stateRefund, statePackage], dataState: .loaded)
    }
}
