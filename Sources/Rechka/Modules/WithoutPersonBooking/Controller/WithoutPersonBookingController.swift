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
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Покупка"
        // Do any additional setup after loading the view.
    }
    
    private func makeState() {
        var states: [State] = []
        for tariff in model.ticketsList {
            var elemets: [Element] = []
            var cunnrentCount = 0
            let tarifSteper = WithoutPersonBookingView.ViewState.TariffSteper(
                tariff: tariff.tariff,
                price: tariff.price,
                stepperCount: String(cunnrentCount),
                onPlus: { count in
                    cunnrentCount = count
                },
                onMinus: { count in
                    cunnrentCount = count
                },
                height: 87).toElement()
            elemets.append(tarifSteper)
            if cunnrentCount > 0 {
                let choicePlace = WithoutPersonBookingView.ViewState.ChoicePlace(onSelect: {}, height: 60).toElement()
                elemets.append(choicePlace)
            }
            let stepperSection = SectionState(header: nil, footer: nil)
            let stepperState = State(model: stepperSection, elements: elemets)
            states.append(stepperState)
        }
        nestedView.viewState = WithoutPersonBookingView.ViewState(title: model.title, state: states, dataState: .loaded)
    }
}
