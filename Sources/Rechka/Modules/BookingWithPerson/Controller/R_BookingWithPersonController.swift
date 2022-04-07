//
//  R_BookingWithPersonController.swift
//  
//
//  Created by Слава Платонов on 21.03.2022.
//

import UIKit
import CoreTableView

protocol R_BookingWithPersonDelegate: AnyObject {
    func setupNewUser(for payment: PaymentModel, and model: FakeModel)
}

internal final class R_BookingWithPersonController: UIViewController {
    
    let nestedView = R_BookingWithPersonView(frame: UIScreen.main.bounds)
    
    var model: FakeModel!
    var paymentModel: [PaymentModel] = []
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRiverBackButton()
        title = "Покупка"
    }
    
    private func makeState(from payment: [PaymentModel]) {
        let users = payment.flatMap({$0.ticket}).map({$0.user})
        let tickets = payment.flatMap({$0.ticket})
        var tickElements: [Element] = []
        // passenger
        var passElements = [Element]()
        let passengerHeaderCell = R_BookingWithPersonView.ViewState.PassengerHeader(
            onAdd: { [weak self] in
                guard let self = self else { return }
                self.pushPersonDataEntry(model: self.model, with: self.paymentModel.last)
            }
        ).toElement()
        passElements.append(passengerHeaderCell)
        
        users.forEach { user in
            tickets.forEach { ticket in
                if ticket.user == user {
                    let passenger = R_BookingWithPersonView.ViewState.Passenger(
                        name: "\(user?.surname ?? "") \(user?.name ?? "")",
                        tariff: ticket.ticket?.tariff ?? ""
                    ).toElement()
                    if !passElements.contains(passenger) {
                        passElements.append(passenger)
                    }
                }
            }
        }
        
        let passengerSection = SectionState(header: nil, footer: nil)
        let passengerState = State(model: passengerSection, elements: passElements)
        
        // tickets
        let tariffHeader = R_BookingWithPersonView.ViewState.TariffHeader().toElement()
        tickElements.append(tariffHeader)
        tickets.forEach { ticket in
            let tariff = R_BookingWithPersonView.ViewState.Tariff(
                tariffs: "\(ticket.ticket?.tariff ?? "") x\(tickets.count)",
                price: ticket.ticket?.price ?? ""
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
                self?.pushPersonDataEntry()
            }
        }()
        
        let viewState = R_BookingWithPersonView.ViewState(
            title: model.title,
            isUserCacheEmpty: SomeCache.shared.cache["user"]?.isEmpty ?? false,
            menuActions: setupPersonMenu(),
            dataState: .addedPersonData([passengerState, tariffState]),
            showPersonAlert: showPersonAlert,
            showPersonDataEntry: showPersonDataEntry
        )
        nestedView.viewState = viewState
    }
    
    private func setupPersonAlert() {
        guard let users = SomeCache.shared.cache["user"] else { return }
        let personAlert = UIAlertController(title: "Persons", message: "", preferredStyle: .actionSheet)
        let addAction = UIAlertAction(title: "Новый пассажир", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.pushPersonDataEntry()
        }
        personAlert.addAction(addAction)
        users.forEach { [weak self] user in
            guard let self = self else { return }
            let action = UIAlertAction(title: "\(user.surname ?? "")", style: .default) { _ in
                self.pushPersonDataEntry(model: self.model, and: user)
            }
            personAlert.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        personAlert.addAction(cancelAction)
        self.present(personAlert, animated: true)
    }
    
    private func setupPersonMenu() -> [UIAction] {
        var actions: [UIAction] = []
        guard let users = SomeCache.shared.cache["user"] else { return [] }
        users.forEach { user in
            let action = UIAction(
                title: "\(user.surname ?? "") \(user.name?.first ?? Character("")). \(user.middleName?.first ?? Character("")).",
                image: UIImage(systemName: "person")) { [weak self] _ in
                    guard let self = self else { return }
                    self.pushPersonDataEntry(model: self.model, with: self.paymentModel.last, and: user)
                }
            actions.append(action)
        }
        let addAction = UIAction(title: "Новый пасажир", image: UIImage(systemName: "plus")) { [weak self] _ in
            guard let self = self else { return }
            self.pushPersonDataEntry()
        }
        actions.append(addAction)
        return actions
    }
    
    private func pushPersonDataEntry(model: FakeModel? = nil, with payment: PaymentModel? = nil, and user: RiverUser? = nil) {
        let passenderDataEntry = R_PassengerDataEntryController()
        passenderDataEntry.delegate = self
        passenderDataEntry.model = self.model
        if payment != nil {
            passenderDataEntry.paymentModel = payment
            passenderDataEntry.displayUser = user
            navigationController?.pushViewController(passenderDataEntry, animated: true)
        } else {
            navigationController?.pushViewController(passenderDataEntry, animated: true)
        }
    }
}

extension R_BookingWithPersonController: R_BookingWithPersonDelegate {
    func setupNewUser(for payment: PaymentModel, and model: FakeModel) {
        self.paymentModel.append(payment)
        self.model = model
        self.makeState(from: self.paymentModel)
    }
}
