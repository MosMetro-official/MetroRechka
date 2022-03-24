//
//  PersonBookingController.swift
//  
//
//  Created by Слава Платонов on 21.03.2022.
//

import UIKit
import CoreTableView

protocol PersonBookingDelegate: AnyObject {
    func setupNewUser(for user: User, and oldModel: FakeModel)
}

class PersonBookingController: UIViewController {
    
    let nestedView = PersonBookingView(frame: UIScreen.main.bounds)
        
    var model: FakeModel!
    var user: User?
    
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
    
    private func makeState(for cacheUser: User? = nil) {
        var elements: [Element] = []
        if cacheUser != nil {
            let passengerHeaderCell = PersonBookingView.ViewState.PassengerHeader(onAdd: {}, height: 50).toElement()
            let passenger = PersonBookingView.ViewState.Passenger(name: "\(cacheUser?.surname ?? "") \(cacheUser?.name ?? "")", tariff: model.ticketsList.first?.tariff ?? "", height: 70).toElement()
            elements.append(contentsOf: [passengerHeaderCell, passenger])
        } else {
            let passengerHeaderCell = PersonBookingView.ViewState.PassengerHeader(onAdd: {}, height: 50).toElement()
            let passenger = PersonBookingView.ViewState.Passenger(name: "\(user?.surname ?? "") \(user?.name ?? "")", tariff: model.ticketsList.first?.tariff ?? "", height: 70).toElement()
            elements.append(contentsOf: [passengerHeaderCell, passenger])
        }
        let passengerSection = SectionState(header: nil, footer: nil)
        let passengerState = State(model: passengerSection, elements: elements)
        
        let tariffHeader = PersonBookingView.ViewState.TariffHeader(height: 50).toElement()
        let tariff = PersonBookingView.ViewState.Tariff(tariffs: model.ticketsList.first?.tariff ?? "", price: model.ticketsList.first!.price, height: 60).toElement()
        let commission = PersonBookingView.ViewState.Commission(commission: "Комиссия сервиса", price: "60 ₽", height: 60).toElement()
        let tariffSection = SectionState(header: nil, footer: nil)
        let tariffState = State(model: tariffSection, elements: [tariffHeader, tariff, commission])
        
        nestedView.state = PersonBookingView.ViewState(state: [], dataState: .addedPersonData([passengerState, tariffState]))
    }
    
    private func setupPersonAlert() {
        nestedView.showPersonAlert = { [weak self] in
            guard let self = self else { return }
            guard let users = SomeCache.shared.cache["user"] as? [User] else { return }
            var actions: [UIAlertAction] = []
            users.forEach { user in
                let action = UIAlertAction(title: "\(user.surname ?? "")", style: .default) { _ in
                    print("action alert")
                    self.pushPersonDataEntry(with: user)
                }
                actions.append(action)
            }
            let personAlert = UIAlertController(title: "Persons", message: "", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            personAlert.addAction(cancelAction)
            self.present(personAlert, animated: true)
        }
        
        nestedView.showPersonDataEntry = {
            self.pushPersonDataEntry(with: self.user, and: self.model)
        }
    }
    
    private func pushPersonDataEntry(with user: User? = nil, and model: FakeModel? = nil) {
        let passenderDataEntry = PassengerDataEntryController()
        passenderDataEntry.delegate = self
        passenderDataEntry.model = model!
        if user != nil {
            passenderDataEntry.user = user!
            navigationController?.pushViewController(passenderDataEntry, animated: true)
        } else {
            navigationController?.pushViewController(passenderDataEntry, animated: true)
        }
    }
    
    private func setupCacheUser() {
        nestedView.showUserFromCache = { [weak self] user in
            guard let self = self else { return }
            self.makeState(for: user)
        }
    }
}

extension PersonBookingController: PersonBookingDelegate {
    func setupNewUser(for user: User, and oldModel: FakeModel) {
        self.user = user
        self.model = oldModel
        self.makeState()
    }
}
