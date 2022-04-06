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
    
    var model: RiverTrip? {
        didSet {
            createInitialSelectedItems()
        }
    }
    
    var selectedTarrifs: [RiverTariff: [RiverUser]] = [:] {
        didSet {
            Task.detached { [weak self] in
                guard let selectedTarrifs = await self?.selectedTarrifs, let state = await self?.makeState(with: selectedTarrifs) else {
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
    }
    
    @MainActor
    private func set(state: WithoutPersonBookingView.ViewState) {
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
        let newState: WithoutPersonBookingView.ViewState = .init(title: self.nestedView.viewState.title,
                                          state: self.nestedView.viewState.state,
                                          dataState: .loaded,
                                          onBooking: self.nestedView.viewState.onBooking)
        self.set(state: newState)
        
        let bookingController = BookingController()
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
            let newState: WithoutPersonBookingView.ViewState = .init(title: self.nestedView.viewState.title,
                                              state: self.nestedView.viewState.state,
                                              dataState: .loading,
                                              onBooking: self.nestedView.viewState.onBooking)
            self.set(state: newState)
            
            Task.detached { [weak self] in
                do {
                    let order = try await RiverTrip.book(with: users, tripID: tripID)
                    await self?.handle(order: order)
                } catch {
                    
                }
            }
        } else {
            let unauthorizedVC = RUnauthorizedController()
            self.present(unauthorizedVC, animated: true, completion: nil)
        }
        
        
    }
    
    private func makeState(with model: [RiverTariff: [RiverUser]]) async -> WithoutPersonBookingView.ViewState? {
        guard let mainModel = self.model else { return nil }
        var resultStates = [State]()
        
        let totalSelectedTicketsCount = self.selectedTarrifs.compactMap { $0.value.count }.reduce(0, +)
        for item in model {
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
            
            
            let tariffElement: Element = WithoutPersonBookingView.ViewState.TariffSteper(
                tariff: tariff.name,
                price: price,
                stepperCount: "\(arrayOfSelection.count)",
                onPlus: onPlus,
                onMinus: onMinus,
                height: 87)
                .toElement()
            let tariffSection = SectionState(header: nil, footer: nil)
            
            resultStates.append(State(model: tariffSection, elements: [tariffElement]))
        }
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
    
    
    
    private func updateCurrentState(with ticketsCount: [String: Int], and model: FakeModel) {
        
    }
}
