//
//  R_BookingWithoutPersonController.swift
//  
//
//  Created by Слава Платонов on 25.03.2022.
//

import UIKit
import CoreTableView
import CoreNetwork

internal final class R_BookingWithoutPersonController: UIViewController {
    
    let nestedView = R_BookingWithoutPersonView(frame: UIScreen.main.bounds)
    
    var model: R_Trip? {
        didSet {
            createInitialSelectedItems()
        }
    }
 
    var selectedTarrifs: SelectionModel = .init(selectedTarrifs: [:], additionServices: [:]) {
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
        NotificationCenter.default.addObserver(forName: .riverSuccessfulAuth, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.startBooking()
        }
    }
    
    private func set(state: R_BookingWithoutPersonView.ViewState) {
        self.nestedView.viewState = state
    }
    
    struct SelectionModel {
        var selectedTarrifs: [R_Tariff: [R_User]]
        var additionServices: [R_Tariff: Int]
    }
    
    private func createInitialSelectedItems() {
        guard let tarrifs = model?.tarrifs else {
            return
        }
        
        
        var initialBaseSelectedTarrifs: [R_Tariff: [R_User]] = [:]
        var initialAdditionServices: [R_Tariff: Int] = [:]
        tarrifs.forEach { tariff in
            switch tariff.type {
            case .base, .default:
                initialBaseSelectedTarrifs.updateValue([], forKey: tariff)
            case .luggage, .good, .additional:
                initialAdditionServices.updateValue(0, forKey: tariff)
            }
        }
        
        self.selectedTarrifs = .init(selectedTarrifs: initialBaseSelectedTarrifs,
                                     additionServices: initialAdditionServices)
        
    }
    
    private func handleOperation(for tariff: R_Tariff, isMinus: Bool) {
        // check for availabilty
        
        switch tariff.type {
        case .base, .default:
            guard var currentCount = self.selectedTarrifs.selectedTarrifs[tariff] else {
                return
            }
            if isMinus {
                currentCount.removeLast()
            } else {
                currentCount.append(.init(ticket: tariff))
            }
            self.selectedTarrifs.selectedTarrifs.updateValue(currentCount, forKey: tariff)
        case .luggage, .good, .additional:
            guard var currentCount = self.selectedTarrifs.additionServices[tariff] else {
                return
            }
            if isMinus {
                currentCount -= 1
            } else {
                currentCount += 1
            }
            self.selectedTarrifs.additionServices.updateValue(currentCount, forKey: tariff)
        }
    }
    
    private func handle(order: RiverOrder) {
        DispatchQueue.main.async {
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
        
    }
    
    private func startBooking() {
        guard let tripID = self.model?.id else { return }
        
        if let _ = Rechka.shared.token {
            var users: [R_User] = self.selectedTarrifs.selectedTarrifs.reduce([]) { partialResult, element in
                var result = partialResult
                result.append(contentsOf: element.value)
                return result
            }
            let additionalServicesCount = self.selectedTarrifs.additionServices.reduce(0, { $0 + $1.value })
            
            // Проверяем, что у нас есть хотя бы один юзер и есть доп услуги
            if let _ = users.first, additionalServicesCount > 0 {
                var selectedServices = [R_AdditionService]()
                for (service,itemsCount) in self.selectedTarrifs.additionServices {
                    if itemsCount > 0 {
                        let array = Array.init(repeating: service.toAdditionService(), count: itemsCount)
                        selectedServices.append(contentsOf: array)
                    }
                }
                users[0].additionServices = selectedServices
            }
            
            
            let newState: R_BookingWithoutPersonView.ViewState = .init(
                title: self.nestedView.viewState.title,
                state: self.nestedView.viewState.state,
                dataState: .loading,
                onBooking: self.nestedView.viewState.onBooking
            )
            self.set(state: newState)
            let finalUsers = users
            
            R_Trip.book(with: finalUsers, tripID: tripID) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let order):
                    self.handle(order: order)
                    return
                case .failure(let error):
                    DispatchQueue.main.async {
                        let onSelect: () -> Void = { [weak self] in
                            guard let self = self else { return }
                            R_Toast.remove(from: self.nestedView)
                            self.nestedView.viewState.dataState = .loaded
                        }
                        
                        let buttonData = R_Toast.Configuration.Button(image: UIImage(systemName: "xmark"), title: nil, onSelect: onSelect)
                        
                        let config = R_Toast.Configuration.defaultError(text: error.errorTitle, subtitle: nil, buttonType: .imageButton(buttonData))
                        let newErrorState: R_BookingWithoutPersonView.ViewState = .init(
                            title: self.nestedView.viewState.title,
                            state: self.nestedView.viewState.state,
                            dataState: .error(config),
                            onBooking: self.nestedView.viewState.onBooking
                        )
                        
                        self.nestedView.viewState = newErrorState
                    }
                }
            }
            
        } else {
            let vc = R_UnauthorizedController()
            vc.onLogin = Command(action: { [weak self] in
                guard let self = self else { return }
                guard let url = URL(string: Rechka.shared.openAuthDeeplink), UIApplication.shared.canOpenURL(url) else {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                })
                
            })
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func showPlaceController(for trip: R_Trip, selectedPlace: Int?, onPlaceSelect: Command<Int>) {
        let controller = R_PlaceController()
        self.present(controller, animated: true) {
            if let selectedPlace = selectedPlace {
                controller.shouldPerformFirstSet = false
                controller.selectedPlace = selectedPlace
            }
            controller.trip = trip
            controller.onPlaceSelect = onPlaceSelect
            
        }
    }
    
    private func makeState(with model: SelectionModel) async -> R_BookingWithoutPersonView.ViewState? {
        guard let mainModel = self.model else { return nil }
        
        let normalHeight = 72.0
        let bigHeight = 100.0
        var resultStates = [State]()
        let totalSelectedTicketsCount = self.selectedTarrifs.selectedTarrifs.compactMap { $0.value.count }.reduce(0, +)
        for item in model.selectedTarrifs {
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
                height: normalHeight,
                serviceInfo: nil,
                tariff: tariff.name,
                price: price,
                stepperCount: "\(arrayOfSelection.count)",
                onPlus: onPlus,
                onMinus: onMinus
            ).toElement()
            ticketElemets.append(tariffElement)
            // Если к билету нужно выбрать место
            if !tariff.isWithoutPlace {
                let placesElements: [Element] = arrayOfSelection.enumerated().map { (index,user) in
                    let onSelectPlace = Command { [weak self] in
                        guard let self = self else { return }
                        let onPlaceSelect: Command<Int> = Command { [weak self] place in
                            guard let self = self, let  _ = self.selectedTarrifs.selectedTarrifs[tariff]?[safe: index]?.ticket else { return }
                            self.selectedTarrifs.selectedTarrifs[tariff]![index].ticket!.place = place
                        }
                        self.showPlaceController(for: mainModel, selectedPlace: user.ticket?.place, onPlaceSelect: onPlaceSelect)
                    }
                    let title = user.ticket?.place == nil ? "Выберите место" : "Пассажир \(index+1) – место \(user.ticket!.place!)"
                    let choicePlaceElement = R_BookingWithoutPersonView.ViewState.ChoicePlace(
                        title: title,
                        onItemSelect: onSelectPlace
                    ).toElement()
                    return choicePlaceElement
                }
                
                ticketElemets.append(contentsOf: placesElements)
            }
            
            let mainTariffSection = SectionState(header: nil, footer: nil)
            resultStates.append(State(model: mainTariffSection, elements: ticketElemets))
        }
        
        if totalSelectedTicketsCount > 0 {
            
            
            for addition in model.additionServices {
                let tariff = addition.key
                let count = addition.value
                let price = "\(Int(tariff.price)) ₽"
                let onPlus = Command(action: { [weak self] in
                    self?.handleOperation(for: tariff, isMinus: false)
                })
                var onMinus: Command<Void>?
                
                if count != 0 {
                    onMinus = Command(action: { [weak self] in
                        self?.handleOperation(for: tariff, isMinus: true)
                    })
                }
                
                let tariffElement: Element = R_BookingWithoutPersonView.ViewState.TariffSteper(
                    height: bigHeight,
                    serviceInfo: "ДОПОЛНИТЕЛЬНАЯ УСЛУГА",
                    tariff: tariff.name,
                    price: price,
                    stepperCount: "\(count)",
                    onPlus: onPlus,
                    onMinus: onMinus
                ).toElement()
                
                let additionalTariffSection = SectionState(header: nil, footer: nil)
                resultStates.append(State(model: additionalTariffSection, elements: [tariffElement]))
            }
        }
        
        
        

       
        
        
        // MARK: – Секция к оплате
        if totalSelectedTicketsCount > 0 {
            
            var paidElements = [Element]()
            let paidTarrifs: [Element] = model.selectedTarrifs.compactMap { selectedTariff in
                guard selectedTariff.value.count > 0 else { return nil }
                let text = "\(selectedTariff.key.name) x\(selectedTariff.value.count)"
                let totalPrice = selectedTariff.key.price * Double(selectedTariff.value.count)
                let priceStr = "\(totalPrice) ₽"
                return R_BookingWithoutPersonView.ViewState.Tariff(
                    tariffs: text,
                    price: priceStr)
                    .toElement()
                
            }
            
            let additional: [Element] = model.additionServices.compactMap { additionalTariff in
                guard additionalTariff.value > 0 else { return nil }
                let text = "\(additionalTariff.key.name) x\(additionalTariff.value)"
                let totalPrice = additionalTariff.key.price * Double(additionalTariff.value)
                let priceStr = "\(totalPrice) ₽"
                return R_BookingWithoutPersonView.ViewState.Tariff(
                    tariffs: text,
                    price: priceStr)
                    .toElement()
            }
            let tariffHeader = R_BookingWithoutPersonView.ViewState.TariffHeader().toElement()
            paidElements.append(tariffHeader)
            paidElements.append(contentsOf: paidTarrifs)
            paidElements.append(contentsOf: additional)
            
            let paidSection = SectionState(header: nil, footer: nil)
            let paidState = State(model: paidSection, elements: paidElements)
            resultStates.append(paidState)
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
}
