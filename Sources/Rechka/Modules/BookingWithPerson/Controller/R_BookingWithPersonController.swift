//
//  R_BookingWithPersonController.swift
//  
//
//  Created by Слава Платонов on 21.03.2022.
//

import UIKit
import CoreTableView
import MMCoreNetworkAsync

internal final class R_BookingWithPersonController: UIViewController {
    
    let nestedView = R_BookingWithPersonView(frame: UIScreen.main.bounds)
    
    var model: R_Trip?
    private var riverUsers: [R_User] = []
    
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
            title: model.name,
            menuActions: setupPersonMenu(),
            dataState: .addPersonData,
            state: [],
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
        guard let tripID = self.model?.id else { return }
        if let _ = Rechka.shared.token {
            R_Trip.book(with: riverUsers, tripID: tripID) { result in
                switch result {
                case .success(let order):
                    self.handle(order: order)
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        let onSelect: () -> Void = { [weak self] in
                            guard let self = self else { return }
                            R_Toast.remove(from: self.nestedView)
                            self.nestedView.viewState.dataState = .addedPersonData
                        }
                        
                        let buttonData = R_Toast.Configuration.Button(image: UIImage(systemName: "xmark"), title: nil, onSelect: onSelect)
                        
                        let config = R_Toast.Configuration.defaultError(text: error.errorTitle, subtitle: nil, buttonType: .imageButton(buttonData))
                        let newErrorState: R_BookingWithPersonView.ViewState = .init(
                            title: self.nestedView.viewState.title,
                            menuActions: self.nestedView.viewState.menuActions,
                            dataState: .error(config),
                            state: self.nestedView.viewState.state,
                            book: self.nestedView.viewState.book
                        )
                        self.nestedView.viewState = newErrorState
                    }
                }
            }
        } else {
            let vc = R_UnauthorizedController()
            vc.onLogin = Command(action: { 
                guard let url = URL(string: Rechka.shared.openAuthDeeplink), UIApplication.shared.canOpenURL(url) else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                })
            })
            self.present(vc, animated: true, completion: nil)
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
        var tickElements : [Element] = []
        let tariffHeader = R_BookingWithPersonView.ViewState.TariffHeader().toElement()
        tickElements.append(tariffHeader)
        var tarrifs = [R_Tariff]()
        riverUsers.forEach { user in
            if let ticket = user.ticket {
                tarrifs.append(ticket)
            }
        }
        let tarrifsGroup = Dictionary(grouping: tarrifs) { $0.name }
        tarrifsGroup.forEach { name, tickets in
            let price = Int(tickets.first?.price ?? 0)
            let tariff = R_BookingWithPersonView.ViewState.Tariff(
                tariffs: "\(name) x\(tickets.count)",
                price: "\(price * tickets.count) ₽"
            ).toElement()
            if !tickElements.contains(tariff) {
                tickElements.append(tariff)
            }
        }
        let additionalService = users.compactMap { $0.additionServices }.filter { !$0.isEmpty }.flatMap { $0 }
        let additionalGroup = Dictionary(grouping: additionalService) { $0.name_ru }
        additionalGroup.forEach { name, additionals in
            let price = Int(additionals.first?.price ?? 0)
            let tariff = R_BookingWithPersonView.ViewState.Tariff(
                tariffs: "\(name) x\(additionals.count)",
                price: "\(price * additionals.count) ₽"
            ).toElement()
            tickElements.append(tariff)
        }
        
        let tariffSection = SectionState(header: nil, footer: nil)
        let tariffState = State(model: tariffSection, elements: tickElements)
        let showPersonAlert = Command { [weak self] in
            self?.setupPersonAlert()
        }
        let showPersonDataEntry = Command { [weak self] in
            self?.pushPersonDataEntry(with: newModel)
        }
        
        let book: Command<Void>? = {
            return Command { [weak self] in
                self?.startBooking()
            }
        }()
        
        let viewState = R_BookingWithPersonView.ViewState(
            title: newModel.name,
            menuActions: setupPersonMenu(),
            dataState: .addedPersonData,
            state: [passengerState, tariffState],
            showPersonAlert: showPersonAlert,
            showPersonDataEntry: showPersonDataEntry,
            book: book
        )
        nestedView.viewState = viewState
    }
    
    private func setupPersonAlert() {
        guard let newModel = model else { return }
        guard let users = SomeCache.shared.cache["user"] else { return }
        let personAlert = UIAlertController(title: "Пассажиры", message: "", preferredStyle: .actionSheet)
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
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
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
}
