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
    var paymentModel: [PaymentModel] = [] {
        didSet {
            print("🔥🔥🔥 paymnet for booking - \(paymentModel)")
        }
    }
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: image for back button
        nestedView.configureTitle(with: model)
        setupPersonAlert()
        setupCacheUser()
        title = "Покупка"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nestedView.onReload()
    }
    
    private func makeState(for cacheUser: RiverUser? = nil, from payment: [PaymentModel]) {
        let users = payment.flatMap({$0.ticket}).map({$0.user})
        let tickets = payment.flatMap({$0.ticket})
        var tickElements: [Element] = []
        // passenger
        var passElements = [Element]()
        let passengerHeaderCell = R_BookingWithPersonView.ViewState.PassengerHeader(
            onAdd: {
                self.pushPersonDataEntry()
            },
            height: 50
        ).toElement()
        passElements.append(passengerHeaderCell)
        
        users.forEach { user in
            tickets.forEach { ticket in
                if ticket.user == user {
                    let passenger = R_BookingWithPersonView.ViewState.Passenger(
                        name: "\(user?.surname ?? "") \(user?.name ?? "")",
                        tariff: ticket.ticket?.tariff ?? "",
                        height: 70
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
        let tariffHeader = R_BookingWithPersonView.ViewState.TariffHeader(height: 50).toElement()
        tickElements.append(tariffHeader)
        tickets.forEach { ticket in
            let tariff = R_BookingWithPersonView.ViewState.Tariff(tariffs: "\(ticket.ticket?.tariff ?? "") x\(tickets.count)", price: ticket.ticket?.price ?? "", height: 60).toElement()
            tickElements.append(tariff)
        }
        let commission = R_BookingWithPersonView.ViewState.Commission(commission: "Комиссия сервиса", price: "60 ₽", height: 60).toElement()
        tickElements.append(commission)
        let tariffSection = SectionState(header: nil, footer: nil)
        let tariffState = State(model: tariffSection, elements: tickElements)
        
        nestedView.state = R_BookingWithPersonView.ViewState(state: [], dataState: .addedPersonData([passengerState, tariffState]))
    }
    
    private func setupPersonAlert() {
        nestedView.showPersonAlert = { [weak self] in
            guard let self = self else { return }
            guard let users = SomeCache.shared.cache["user"] else { return }
            var actions: [UIAlertAction] = []
            users.forEach { user in
                let action = UIAlertAction(title: "\(user.surname ?? "")", style: .default) { _ in
                    print("action alert")
                    self.pushPersonDataEntry(model: self.model, and: user)
                }
                actions.append(action)
            }
            let personAlert = UIAlertController(title: "Persons", message: "", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            personAlert.addAction(cancelAction)
            self.present(personAlert, animated: true)
        }
        
        nestedView.showPersonDataEntry = { [weak self] in
            guard let self = self else { return }
            self.pushPersonDataEntry(model: self.model, with: self.paymentModel.first)
        }
    }
    
    private func pushPersonDataEntry(model: FakeModel? = nil, with payment: PaymentModel? = nil, and user: RiverUser? = nil) {
        let passenderDataEntry = R_PassengerDataEntryController()
        passenderDataEntry.delegate = self
//        if let model = model {
            passenderDataEntry.model = self.model
//        }
        if payment != nil {
            passenderDataEntry.paymentModel = payment
            passenderDataEntry.displayUser = user
            navigationController?.pushViewController(passenderDataEntry, animated: true)
        } else {
            navigationController?.pushViewController(passenderDataEntry, animated: true)
        }
    }
    
    private func setupCacheUser() {
        nestedView.showUserFromCache = { [weak self] user in
            guard let self = self else { return }
            //self.pushPersonDataEntry(model: self.model, with: self.paymentModel)
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
