//
//  R_BookingWithPersonController.swift
//  
//
//  Created by Слава Платонов on 21.03.2022.
//

import UIKit
import CoreTableView

protocol R_BookingWithPersonDelegate: AnyObject {
    func setupNewUser(with user: R_User, and model: R_Trip)
}

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

        let showPersonDataEntry: Command<Void>? = {
            return Command { [weak self] in
                self?.pushPersonDataEntry(with: (model))
            }
        }()
        let showPersonAlert: Command<Void>? = {
            return Command { [weak self] in
                self?.setupPersonAlert()
            }
        }()
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
    
    private func makeState(from riverUsers: [R_User]) {
        guard let newModel = model else { return }
        let users = riverUsers.map({$0})
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
        
        users.forEach { user in
            let passenger = R_BookingWithPersonView.ViewState.Passenger(
                name: "\(user.surname ?? "") \(user.name ?? "")",
                tariff: user.ticket?.name ?? ""
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
        let tickets = riverUsers.map({$0.ticket})
        tickets.forEach { ticket in
            let tariff = R_BookingWithPersonView.ViewState.Tariff(
                tariffs: "\(ticket?.name ?? "")",
                price: "\(Int(ticket?.price ?? 0)) ₽"
            ).toElement()
            tickElements.append(tariff)
        }
        let commission = R_BookingWithPersonView.ViewState.Commission(commission: "Комиссия сервиса", price: "60 ₽").toElement()
        tickElements.append(commission)
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
                //self?.startBooking()
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
        print("🤷‍♂️🤷‍♂️🤷‍♂️ \(users)")
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
    
    private func pushPersonDataEntry(with model: R_Trip, and user: R_User? = nil) {
        let passenderDataEntry = R_PassengerDataEntryController()
        passenderDataEntry.delegate = self
        passenderDataEntry.model = model
        if user != nil {
            passenderDataEntry.displayRiverUsers.append(user!)
            navigationController?.pushViewController(passenderDataEntry, animated: true)
        } else {
            navigationController?.pushViewController(passenderDataEntry, animated: true)
        }
    }
}

extension R_BookingWithPersonController: R_BookingWithPersonDelegate {
    func setupNewUser(with user: R_User, and model: R_Trip) {
        self.riverUsers.append(user)
        self.model = model
        self.makeState(from: riverUsers)
    }
}
