//
//  PassengerDataEntryController.swift
//  
//
//  Created by Слава Платонов on 23.03.2022.
//

import UIKit
import CoreTableView

class PassengerDataEntryController : UIViewController {
    
    weak var delegate: PersonBookingDelegate?
    private let nestedView = PassengerDataEntryView(frame: UIScreen.main.bounds)
    
    var displayUser: RiverUser! {
        didSet {
            makeState()
        }
    }
        
    var model: FakeModel! {
        didSet {
            if paymentModel == nil {
                firstSetup()
            }
            makeState()
        }
    }
    
    var paymentModel: PaymentModel? {
        didSet {
            setupValidate()
        }
    }
        
    private var inputStates = [InputView.ViewState]()
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReadyButton()
        title = "Пассажир"
    }
    
    private func firstSetup() {
        let user = RiverUser()
        displayUser = user
        let ticket = FakeTickets(price: "100500", tariff: "ЕдиныЙ")
        self.paymentModel = PaymentModel(ticket: [Ticket(user: user, ticket: ticket)])
    }
    
    private func makeState() {
        self.inputStates.removeAll()
        if let model = paymentModel {
            var finalState = [State]()
            let users = model.ticket.compactMap({ $0.user })
            self.inputStates.removeAll()
            for (index, user) in users.enumerated() {
                let tableState = createTableState(for: user, index: index)
                finalState.append(contentsOf: tableState)
            }
            self.nestedView.viewState = PassengerDataEntryView.ViewState(state: finalState, dataState: .loaded, onSave: {} )
        }
    }
    
    private func setupReadyButton() {
        nestedView.onReadySelect = { [weak self] in
            guard let self = self else { return }
            guard let users = self.paymentModel?.ticket.map( {$0.user} ) else { return }
            for user in users {
                if let user = user {
                    SomeCache.shared.addToCache(user: user)
                }
            }
            self.popToBooking()
        }
    }
    
    private func setupValidate() {
        nestedView.validate = {
            guard let users = self.paymentModel?.ticket.compactMap( {$0.user }) else { return false }
            var result = false
            for user in users {
                if user.surname != nil {
                    result = true
                }
            }
            return result
        }
    }
    
    private func popToBooking() {
        guard let paymentModel = paymentModel else { return }
        delegate?.setupNewUser(for: paymentModel, and: model)
        navigationController?.popViewController(animated: true)
    }
}

extension PassengerDataEntryController {
    
    private func createInputField(index: Int, text: String?, desc: String, placeholder: String, keyboardType: UIKeyboardType, onTextEnter: @escaping (TextEnterData) -> Void, validation: ((TextValidationData) -> Bool)? = nil) -> InputView.ViewState {
        let onNext: () -> () = {
            if let current = self.inputStates.firstIndex(where: {  $0.id == index }), let next = self.inputStates[safe: current + 1] {
                self.nestedView.showInput(with: next)
            } else {
                self.nestedView.hideInput()
            }
        }
        
        let onBack: () -> () = {
            if let current = self.inputStates.firstIndex(where: {  $0.id == index }), let prevous = self.inputStates[safe: current - 1] {
                self.nestedView.showInput(with: prevous)
            }
        }
        var isFirst = true
        if let first = self.inputStates.first {
            isFirst = first.id == index
        }
        let passengersCount = self.paymentModel?.ticket.compactMap( { $0.user} ).count ?? 0
        
        let isLast = ((passengersCount - 1) * 10 + 5) == index
        
        let nextEndImage = UIImage(named: "addPlus", in: .module, with: nil)
        let nextImage = UIImage(named: "backButton", in: .module, with: nil)
        
        return .init(
            id: index,
            desc: desc,
            text: text,
            placeholder: placeholder,
            onTextEnter: onTextEnter,
            keyboardType: keyboardType,
            onNext: onNext,
            onBack: onBack,
            nextImage: (isLast ? nextEndImage : nextImage) ?? UIImage(),
            backImageEnabled: !isFirst,
            validation: validation
        )
    }
    
    private func passengerFieldExists(for index: Int) -> Bool {
        if let _ = self.paymentModel?.ticket.compactMap( { $0.user} )[safe: index] {
            return true
        }
        return false
    }
    
    private func createTableState(for user: RiverUser, index: Int) -> [State] {
        var sections = [State]()
        let titleElement = PassengerDataEntryView.ViewState.Header(title: "Личные данные", height: 50).toElement()
        
        var personalItems = [Element]()
        personalItems.append(titleElement)

        let onSurnameEnter: (TextEnterData) -> () = { data in
            if self.passengerFieldExists(for: index) {
                self.paymentModel?.ticket[index].user?.surname = data.text.isEmpty ? nil : data.text
                self.displayUser.surname = data.text.isEmpty ? nil : data.text
            }
        }
        
        let surnameState = self.createInputField(index: (index * 10) + 2,
                                                 text: user.surname,
                                                 desc: "Фамилия",
                                                 placeholder: "Иванов",
                                                 keyboardType: .default,
                                                 onTextEnter: onSurnameEnter)
        self.inputStates.append(surnameState)
        
        let surnameField = PassengerDataEntryView.ViewState.Filed(text: user.surname == nil ? "Фамилия" : user.surname!, height: 50) {
            self.nestedView.showInput(with: surnameState)
        }.toElement()
        
        // name
        let onNameEnter: (TextEnterData) -> () = { data in
            if self.passengerFieldExists(for: index) {
                self.paymentModel?.ticket[index].user?.name = data.text.isEmpty ? nil : data.text
                self.displayUser.name = data.text.isEmpty ? nil : data.text
            }
        }
        
        let nameState = self.createInputField(index: (index * 10) + 1,
                                              text: user.name,
                                              desc: "Имя",
                                              placeholder: "Иван",
                                              keyboardType: .default,
                                              onTextEnter: onNameEnter)
        self.inputStates.append(nameState)
        
        let nameField = PassengerDataEntryView.ViewState.Filed(text: user.name == nil ? "Имя" : user.name!, height: 50) {
            self.nestedView.showInput(with: nameState)
        }.toElement()
        
        // middle name
        let onMiddleNameEnter: (TextEnterData) -> () = { data in
            if self.passengerFieldExists(for: index) {
                self.paymentModel?.ticket[index].user?.middleName = data.text.isEmpty ? nil : data.text
                self.displayUser.middleName = data.text.isEmpty ? nil : data.text
            }
        }
        
        let middleNameState = self.createInputField(index: (index * 10) + 3,
                                                    text: user.middleName,
                                                    desc: "Отчество",
                                                    placeholder: "Иванович",
                                                    keyboardType: .default,
                                                    onTextEnter: onMiddleNameEnter)
        self.inputStates.append(middleNameState)
        
        let middleNameField = PassengerDataEntryView.ViewState.Filed(text: user.middleName == nil ? "Отчество" : user.middleName!, height: 50) {
            self.nestedView.showInput(with: middleNameState)
        }.toElement()
        
        personalItems.append(contentsOf: [surnameField, nameField, middleNameField])
        let onBirthdayEnter: (TextEnterData) -> () = { data in
            if self.passengerFieldExists(for: index) {
                self.paymentModel?.ticket[index].user?.birthday = data.text.isEmpty ? nil : data.text
                self.displayUser.birthday = data.text.isEmpty ? nil : data.text
            }
        }
        
        let validation: (TextValidationData) -> Bool = { [weak self] data in
            guard let validationData = self?.birtdayValidation(text: data.text, replacement: data.replacementString) else { return true }
            data.textField.text = validationData.0
            return validationData.1
        }
        
        let birthdayState = self.createInputField(index: (index * 10) + 4,
                                                  text: user.birthday,
                                                  desc: "День рождения",
                                                  placeholder: "01.01.2000",
                                                  keyboardType: .numberPad,
                                                  onTextEnter: onBirthdayEnter,
                                                  validation: validation)
        
        self.inputStates.append(birthdayState)
        
        let birthdayField = PassengerDataEntryView.ViewState.Filed(text: user.birthday == nil ? "День рождения" : user.birthday!, height: 50) {
            self.nestedView.showInput(with: birthdayState)
        }.toElement()
        personalItems.append(birthdayField)
        
        // phone
        let onPhoneEnter: (TextEnterData) -> () = { data in
            if self.passengerFieldExists(for: index) {
                self.paymentModel?.ticket[index].user?.phoneNumber = data.text.isEmpty ? nil : data.text
                self.displayUser.phoneNumber = data.text.isEmpty ? nil : data.text
            }
        }
        
        let phoneValidation: (TextValidationData) -> Bool = { [weak self] data in
            guard let validationData = self?.phoneValidation(text: data.text, replacement: data.replacementString) else { return true }
            data.textField.text = validationData.0
            return validationData.1
        }
        
        let phoneState = self.createInputField(index: (index * 10) + 5,
                                               text: user.phoneNumber == nil ? "+7" : user.phoneNumber!,
                                               desc: "Телефон",
                                               placeholder: "+7 900 000 00 00",
                                               keyboardType: .numberPad,
                                               onTextEnter: onPhoneEnter,
                                               validation: phoneValidation)
        
        self.inputStates.append(phoneState)
        
        let phoneField = PassengerDataEntryView.ViewState.Filed(text: user.phoneNumber == nil ? "Телефон" : user.phoneNumber!, height: 50) {
            self.nestedView.showInput(with: phoneState)
        }.toElement()
        personalItems.append(phoneField)
        
        let genderField = PassengerDataEntryView.ViewState.GenderCell(gender: user.gender ?? .male, onTap: { gender in
            self.paymentModel?.ticket[index].user?.gender = gender
        }, height: 50).toElement()
        personalItems.append(genderField)
        
        let personalDataSectionState = SectionState(header: nil, footer: nil)
        sections.append(State(model: personalDataSectionState, elements: personalItems))
                
        let onCountrySelect: () -> () = {
            // select country
        }
        let countryTitle = PassengerDataEntryView.ViewState.Header(title: "Гражданство", height: 50).toElement()
        let countrySelection = PassengerDataEntryView.ViewState.SelectField(title: "Указать гражданство", height: 50) {
            // open citizenship list
        }.toElement()
        let countrySection = SectionState(header: nil, footer: nil)
        let countryState = State(model: countrySection, elements: [countryTitle, countrySelection])
        sections.append(countryState)
        
        // documents
        let onDocSelect: () -> () = {
            // select document
        }
        
        let docTitle = PassengerDataEntryView.ViewState.Header(title: "Документ", height: 50).toElement()
        let docSelection = PassengerDataEntryView.ViewState.SelectField(title: "Выбрать документ", height: 50) {
            // open document list
        }.toElement()
        let docSection = SectionState(header: nil, footer: nil)
        let docState = State(model: docSection, elements: [docTitle, docSelection])
        sections.append(docState)
        
        // tickets
        let tickets = PassengerDataEntryView.ViewState.Tickets(
            ticketList: model,
            onChoice: { ticketIndex in
                // handle ticket for payment model
                let choiceTicket = self.model.ticketsList[ticketIndex]
                self.paymentModel?.ticket[index].ticket = choiceTicket
            },
            isSelectable: true,
            height: 130
        ).toElement()
        let ticketsHeader = PassengerDataEntryView.ViewState.TariffHeader(
            title: "Тариф",
            ticketsCount: model.ticketsCount,
            isInsetGroup: true,
            height: 50
        )
        let ticketsSection = SectionState(header: ticketsHeader, footer: nil)
        let ticketsState = State(model: ticketsSection, elements: [tickets])
        sections.append(ticketsState)
        
        if !model.isWithoutPlace {
            let choicePlace = WithoutPersonBookingView.ViewState.ChoicePlace(onSelect: {}, height: 60).toElement()
            let choiceSec = SectionState(header: nil, footer: nil)
            let choiceState = State(model: choiceSec, elements: [choicePlace])
            sections.append(choiceState)
        }
        return sections
    }
    
    private func birtdayValidation(text: String, replacement: String) -> (String,Bool) {
        
        if replacement == "" {
            return (text,true)
        }
        
        var _text = text
        if _text.count == 2 || _text.count == 5 {
            _text.append(".")
        }
        
        if _text.count >= 10 {
            return (_text,false)
        }
        
        return (_text,true)
    }
    
    private func phoneValidation(text: String, replacement: String) -> (String,Bool) {
        if replacement == "" {
            if text == "+7" {
                return (text,false)
            }
            return (text,true)
        }
        
        var _text = text
        if _text.count == 2 || _text.count == 6 || _text.count == 10 || _text.count == 13 {
            _text.append(" ")
        }
        
        if _text.count >= 16 {
            return (_text,false)
        }
        
        return (_text,true)
    }
}
