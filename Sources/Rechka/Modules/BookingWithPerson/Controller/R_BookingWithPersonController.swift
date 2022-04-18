//
//  R_BookingWithPersonController.swift
//  
//
//  Created by Слава Платонов on 21.03.2022.
//

import UIKit
import CoreTableView
import CoreNetwork

internal final class R_BookingWithPersonController: UIViewController {
    
    let nestedView = R_BookingWithPersonView(frame: UIScreen.main.bounds)
        
    var model: R_Trip?
    var riverUsers: [R_User] = []
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRiverBackButton()
        createInitialState()
        title = "Покупка"
    }
    
    private func createInitialState() {
        guard let model = model else {
            return
        }

        let showPersonDataEntry = Command { [weak self] in
            self?.pushPersonDataEntry(with: model)
        }
        
        let showPersonAlert = Command { [weak self] in
            self?.setupPersonAlert()
        }
        
        let viewState = R_BookingWithPersonView.ViewState(
            title: "",
            menuActions: setupPersonMenu(),
            dataState: .addPersonData,
            showPersonAlert: showPersonAlert,
            showPersonDataEntry: showPersonDataEntry,
            book: nil
        )
        nestedView.viewState = viewState
    }
    
    private func handle(order: RiverOrder) {
        self.nestedView.removeBlurLoading()
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
        self.nestedView.showBlurLoading()
        guard let tripID = self.model?.id else { return }
        if let _ = Rechka.shared.token {
            let finalUsers = riverUsers
            R_Trip.book(with: finalUsers, tripID: tripID) { result in
                switch result {
                case .success(let order):
                    self.handle(order: order)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else {
            self.nestedView.removeBlurLoading()
            let unauthorizedVC = R_UnauthorizedController()
            self.present(unauthorizedVC, animated: true, completion: nil)
        }
    }
    
    private func makeState(from riverUsers: [R_User]) {
        guard let newModel = model else { return }
        let users = riverUsers.map { $0 }
        // passenger header with add button
        var passElements = [Element]()
        let passengerHeaderCell = R_BookingWithPersonView.ViewState.PassengerHeader(
            onAdd: { [weak self] in
                guard let self = self else { return }
                if riverUsers.count < newModel.buyPlaceCountMax {
                    self.pushPersonDataEntry(with: newModel)
                }
            }
        ).toElement()
        passElements.append(passengerHeaderCell)
        
        for (index, user) in users.enumerated() {
            let onSelect: () -> Void = { [weak self] in
                self?.pushPersonDataEntry(with: newModel, and: user, for: index)
            }
            let passenger = R_BookingWithPersonView.ViewState.Passenger(
                name: "\(user.surname ?? "") \(user.name ?? "")",
                tariff: user.ticket?.name ?? "",
                onSelect: onSelect
            ).toElement()
            if !passElements.contains(passenger) {
                passElements.append(passenger)
            }
        }
        let passengerSection = SectionState(header: nil, footer: nil)
        let passengerState = State(model: passengerSection, elements: passElements)
        
        // tickets
        var tickElements: [Element] = []
        let tariffHeader = R_BookingWithPersonView.ViewState.TariffHeader().toElement()
        tickElements.append(tariffHeader)
        let tickets = users.compactMap { $0.ticket }
        tickets.forEach { ticket in
            let price = Int(ticket.price)
            let tariff = R_BookingWithPersonView.ViewState.Tariff(
                tariffs: ticket.name,
                price: "\(price) ₽"
            ).toElement()
            tickElements.append(tariff)
//            if !tickElements.contains(tariff) {
//                tickElements.append(tariff)
//            }
        }
        let additionalService = users.compactMap { $0.additionServices }.flatMap { $0 }
        additionalService.forEach { service in
            let price = Int(service.price)
            let tariff = R_BookingWithPersonView.ViewState.Tariff(
                tariffs: service.name_ru,
                price: "\(price) ₽"
            ).toElement()
            tickElements.append(tariff)
        }
        
        let tariffSection = SectionState(header: nil, footer: nil)
        let tariffState = State(model: tariffSection, elements: tickElements)
        let showPersonAlert: Command<Void>? = {
            return Command { [weak self] in
                self?.setupPersonAlert()
            }
        }()
        let showPersonDataEntry: Command<Void>? = {
            return Command { [weak self] in
                self?.pushPersonDataEntry(with: newModel)
            }
        }()
        
        let book: Command<Void>? = {
            return Command { [weak self] in
                self?.startBooking()
            }
        }()
        
        let viewState = R_BookingWithPersonView.ViewState(
            title: newModel.name,
            menuActions: setupPersonMenu(),
            dataState: .addedPersonData([passengerState, tariffState]),
            showPersonAlert: showPersonAlert,
            showPersonDataEntry: showPersonDataEntry,
            book: book
        )
        nestedView.viewState = viewState
    }
    
    private func setupPersonAlert() {
        guard let newModel = model else { return }
        guard let users = SomeCache.shared.cache["user"] else { return }
        let personAlert = UIAlertController(title: "Persons", message: "", preferredStyle: .actionSheet)
        let addAction = UIAlertAction(title: "Новый пассажир", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.pushPersonDataEntry(with: newModel)
        }
        personAlert.addAction(addAction)
        users.forEach { [weak self] user in
            guard let self = self else { return }
            let action = UIAlertAction(title: "\(user.surname ?? "")", style: .default) { _ in
                self.pushPersonDataEntry(with: newModel, and: user)
            }
            personAlert.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        personAlert.addAction(cancelAction)
        self.present(personAlert, animated: true)
    }
    
    private func setupPersonMenu() -> [UIAction] {
        guard let newModel = model else { return [] }
        var actions: [UIAction] = []
        guard let users = SomeCache.shared.cache["user"] else { return [] }
        for user in users {
            let action = UIAction(
                title: "\(user.surname ?? "") \(user.name?.first ?? Character("")). \(user.middleName?.first ?? Character("")).",
                image: UIImage(systemName: "person")) { [weak self] _ in
                    guard let self = self else { return }
                    self.pushPersonDataEntry(with: newModel, and: user)
                }
            actions.append(action)
        }
        let addAction = UIAction(title: "Новый пасажир", image: UIImage(systemName: "plus")) { [weak self] _ in
            guard let self = self else { return }
            self.pushPersonDataEntry(with: newModel)
        }
        actions.append(addAction)
        return actions
    }
    
    private func setupNewUser() {
        let passenderDataEntry = R_PassengerDataEntryController()
        passenderDataEntry.setupUser = { [weak self] user, index, model in
            guard let self = self else { return }
            if index != nil {
                self.riverUsers[index!] = user
                self.model = model
                self.makeState(from: self.riverUsers)
            } else {
                self.model = model
                self.riverUsers.append(user)
                self.makeState(from: self.riverUsers)
            }
        }
    }
    
    private func pushPersonDataEntry(with model: R_Trip, and user: R_User? = nil, for index: Int? = nil) {
        let passenderDataEntry = R_PassengerDataEntryController()
        passenderDataEntry.model = model
        if user != nil {
            passenderDataEntry.displayRiverUser = user!
            passenderDataEntry.index = index
            navigationController?.pushViewController(passenderDataEntry, animated: true)
        } else {
            navigationController?.pushViewController(passenderDataEntry, animated: true)
        }
        setupNewUser()
    }
}
