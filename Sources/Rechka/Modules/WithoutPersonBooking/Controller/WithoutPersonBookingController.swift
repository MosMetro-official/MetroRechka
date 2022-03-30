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
    
    // TODO: Заменить на два массива
    private var ticketsCount: [String: Int] = [:] {
        didSet {
            print(ticketsCount)
            makeState()
        }
    }
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTicketsCount()
        title = "Покупка"
    }
    
    private func createTicketsCount() {
        for ticket in model.ticketsList {
            ticketsCount[ticket.tariff] = 0
        }
    }
    
    private func makeState() {
        createDefaultState(with: model)
    }
    
    private func createDefaultState(with model: FakeModel) {
        var states: [State] = []
        var tariffs: [Element] = []
        for tariff in model.ticketsList {
            var elemets: [Element] = []
            let tarifSteper = WithoutPersonBookingView.ViewState.TariffSteper(
                tariff: tariff.tariff,
                price: tariff.price,
                stepperCount: String(ticketsCount[tariff.tariff] ?? 0),
                onPlus: { [weak self] count in
                    self?.ticketsCount[tariff.tariff] = count
                },
                onMinus: { [weak self] count in
                    self?.ticketsCount[tariff.tariff] = count
                },
                height: 87).toElement()
            elemets.append(tarifSteper)
            if !model.isWithoutPlace {
                if ticketsCount[tariff.tariff] != 0 {
                    let choicePlace = WithoutPersonBookingView.ViewState.ChoicePlace(onSelect: {}, height: 60).toElement()
                    elemets.append(choicePlace)
                    var price = 0
                    if let number = Int(tariff.price.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                        price = number
                    }
                    let tariff = WithoutPersonBookingView.ViewState.Tariff(
                        tariffs: tariff.tariff,
                        price: "\(price * (ticketsCount[tariff.tariff] ?? 0)) ₽",
                    height: 60).toElement()
                    if !tariffs.contains(tariff) {
                        tariffs.append(tariff)
                    }
                }
            }
            let stepperSection = SectionState(header: nil, footer: nil)
            let stepperState = State(model: stepperSection, elements: elemets)
            states.append(stepperState)
        }
        let tariffHeader = WithoutPersonBookingView.ViewState.TariffHeader(height: 50).toElement()
        let commission = WithoutPersonBookingView.ViewState.Commission(commission: "Комиссия сервиса", price: "60 ₽", height: 60).toElement()
        if !tariffs.isEmpty {
            tariffs.insert(tariffHeader, at: 0)
            tariffs.append(commission)
        }
        let sec = SectionState(header: nil, footer: nil)
        let tariffState = State(model: sec, elements: tariffs)
        states.append(tariffState)
        nestedView.viewState = WithoutPersonBookingView.ViewState(title: model.title, state: states, dataState: .loaded)
    }
    
    private func updateCurrentState(with ticketsCount: [String: Int], and model: FakeModel) {
        
    }
}
