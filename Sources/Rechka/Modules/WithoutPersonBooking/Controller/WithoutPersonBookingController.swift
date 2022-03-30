//
//  WithoutPersonBookingController.swift
//  
//
//  Created by Слава Платонов on 25.03.2022.
//

import UIKit
import CoreTableView

class WithoutPersonBookingController: UIViewController {
    
    let nestedView = WithoutPersonBookingView(frame: UIScreen.main.bounds)
    var model: FakeModel! {
        didSet {
            makeState()
        }
    }
    private var ticketsCount: [String: Int] = [:] {
        didSet {
            print(ticketsCount)
        }
    }
    private var totalTicketsCount: Int = 0 {
        didSet {
            print(totalTicketsCount)
        }
    }
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Покупка"
    }
    
    private func makeState() {
        createDefaultState(with: model)
    }
    
    private func createDefaultState(with model: FakeModel) {
        var states: [State] = []
        for tariff in model.ticketsList {
            var elemets: [Element] = []
            var currentCount = 0
            let tarifSteper = WithoutPersonBookingView.ViewState.TariffSteper(
                tariff: tariff.tariff,
                price: tariff.price,
                stepperCount: String(currentCount),
                onPlus: { [weak self] count in
                    currentCount = count
                    self?.totalTicketsCount += 1
                    self?.ticketsCount[tariff.tariff] = count
                },
                onMinus: { [weak self] count in
                    currentCount = count
                    self?.totalTicketsCount -= 1
                    self?.ticketsCount[tariff.tariff] = count
                },
                height: 87).toElement()
            elemets.append(tarifSteper)
//            if !model.isWithoutPlace {
//                let choicePlace = WithoutPersonBookingView.ViewState.ChoicePlace(onSelect: {}, height: 60).toElement()
//                elemets.append(choicePlace)
//            }
            let stepperSection = SectionState(header: nil, footer: nil)
            let stepperState = State(model: stepperSection, elements: elemets)
            states.append(stepperState)
        }
        nestedView.viewState = WithoutPersonBookingView.ViewState(title: model.title, state: states, dataState: .loaded)
    }
    
    private func updateCurrentState(with ticketsCount: [String: Int], and model: FakeModel) {
        
    }
}
