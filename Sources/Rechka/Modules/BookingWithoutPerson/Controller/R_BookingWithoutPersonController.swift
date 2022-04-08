//
//  R_BookingWithoutPersonController.swift
//  
//
//  Created by Слава Платонов on 25.03.2022.
//

import UIKit
import CoreTableView

internal final class R_BookingWithoutPersonController: UIViewController {
    
    let nestedView = R_BookingWithoutPersonView(frame: UIScreen.main.bounds)
    
    var model: RiverTrip? {
        didSet {
            createInitialSelectedItems()
        }
    }
 
    var selectedTarrifs: [RiverTariff: [RiverUser]] = [:] {
        didSet {
            Task.detached { [weak self] in
                guard let selectedTarrifs = await self?.selectedTarrifs,
                      let state = await self?.makeState(with: selectedTarrifs) else {
                    return
                }
                await self?.set(state: state)
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Покупка"
        setupRiverBackButton()
    }
    
    @MainActor
    private func set(state: R_BookingWithoutPersonView.ViewState) {
        self.nestedView.viewState = state
    }
    
    private func createInitialSelectedItems() {
        guard let tarrifs = model?.tarrifs else {
            return
        }
        var initialSelectedTarrifs: [RiverTariff: [RiverUser]] = [:]
        tarrifs.forEach {
            initialSelectedTarrifs.updateValue([], forKey: $0)
        }
        self.selectedTarrifs = initialSelectedTarrifs
    }
    
    private func handleOperation(for tariff: RiverTariff, isMinus: Bool) {
        // check for availabilty
        guard var currentCount = self.selectedTarrifs[tariff] else {
            return
        }
        if isMinus {
            currentCount.removeLast()
        } else {
            currentCount.append(.init(ticket: tariff))
        }
        self.selectedTarrifs.updateValue(currentCount, forKey: tariff)   
    }
    
    
    @MainActor
    private func handle(order: RiverOrder) {
        let newState: R_BookingWithoutPersonView.ViewState = .init(
            title: self.nestedView.viewState.title,
            state: self.nestedView.viewState.state,
            dataState: .loaded,
            onBooking: self.nestedView.viewState.onBooking
        )
        self.set(state: newState)
        
        let bookingController = R_BookingScreenController()
        self.present(bookingController, animated: true) {
            bookingController.model = order
            bookingController.onDismiss = { [weak self] in
                self?.navigationController?.popToRootViewController(animated: false)
                NotificationCenter.default.post(name: .riverShowOrder, object: nil, userInfo: ["orderID": order.id])
            }
        }
    }
    
    private func startBooking() {
        guard let tripID = self.model?.id else { return }
        if let _ = Rechka.shared.token {
            let users: [RiverUser] = self.selectedTarrifs.reduce([]) { partialResult, element in
                var result = partialResult
                result.append(contentsOf: element.value)
                return result
            }
            let newState: R_BookingWithoutPersonView.ViewState = .init(
                title: self.nestedView.viewState.title,
                state: self.nestedView.viewState.state,
                dataState: .loading,
                onBooking: self.nestedView.viewState.onBooking
            )
            self.set(state: newState)
            
            Task.detached { [weak self] in
                do {
                    let order = try await RiverTrip.book(with: users, tripID: tripID)
                    await self?.handle(order: order)
                } catch {
                    
                }
            }
        } else {
            let unauthorizedVC = R_UnauthorizedController()
            self.present(unauthorizedVC, animated: true, completion: nil)
        }
    }
    
    private func makeState(with model: [RiverTariff: [RiverUser]]) async -> R_BookingWithoutPersonView.ViewState? {
        guard let mainModel = self.model else { return nil }
        var resultStates = [State]()
        var paidElements = [Element]()
        let totalSelectedTicketsCount = self.selectedTarrifs.compactMap { $0.value.count }.reduce(0, +)
        for item in model {
            var ticketElemets = [Element]()
            let tariff = item.key
            let arrayOfSelection = item.value
            let price = "\(Int(tariff.price)) ₽"
            var onPlus: Command<Void>?
            var onMinus: Command<Void>?
            // Если не равно 0, то активируем минус
            if arrayOfSelection.count != 0 {
                onMinus = Command(action: { [weak self] in
                    self?.handleOperation(for: tariff, isMinus: true)
                })
            }
            // Если количество билетов меньше или равно максимальному количеству возможных для покупки
            if totalSelectedTicketsCount < mainModel.buyPlaceCountMax {
                onPlus = Command(action: { [weak self] in
                    self?.handleOperation(for: tariff, isMinus: false)
                })
            }
        
            let tariffElement: Element = R_BookingWithoutPersonView.ViewState.TariffSteper(
                tariff: tariff.name,
                price: price,
                stepperCount: "\(arrayOfSelection.count)",
                onPlus: onPlus,
                onMinus: onMinus
            ).toElement()
            ticketElemets.append(tariffElement)
            // Если к билету нужно выбрать место
            if arrayOfSelection.count != 0 {
                if !tariff.isWithoutPlace {
                    let choicePlaceElement: Element = R_BookingWithoutPersonView.ViewState.ChoicePlace(onSelect: nil).toElement()
                    ticketElemets.append(choicePlaceElement)
                }
            }
            // Секция к оплате
            if selectedTarrifs[tariff]?.count != 0 {
                let intPrice = Int(tariff.price)
                let tariff = R_BookingWithoutPersonView.ViewState.Tariff(
                    tariffs: "\(tariff.name) x\(selectedTarrifs[tariff]?.count ?? 1)",
                    price: "\(intPrice * (selectedTarrifs[tariff]?.count ?? 0)) ₽"
                ).toElement()
                if !paidElements.contains(tariff) {
                    paidElements.append(tariff)
                }
            }
            let tariffSection = SectionState(header: nil, footer: nil)
            resultStates.append(State(model: tariffSection, elements: ticketElemets))
        }
        
        let tariffHeader = R_BookingWithoutPersonView.ViewState.TariffHeader().toElement()
        let commission = R_BookingWithoutPersonView.ViewState.Commission(
            commission: "Комиссия сервиса",
            price: "60 ₽"
        ).toElement()
        if !paidElements.isEmpty {
            paidElements.insert(tariffHeader, at: 0)
            paidElements.append(commission)
        }
        let sec = SectionState(header: nil, footer: nil)
        let paidState = State(model: sec, elements: paidElements)
        resultStates.append(paidState)
        
        let onBooking: Command<Void>? = {
            if totalSelectedTicketsCount > 0 {
                return Command { [weak self] in
                    self?.startBooking()
                }
            } else {
                return nil
            }
        }()
        
        return .init(title: mainModel.name, state: resultStates, dataState: .loaded, onBooking: onBooking)
    }
}
