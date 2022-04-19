//
//  R_PassengerDataEntryController.swift
//  
//
//  Created by Слава Платонов on 23.03.2022.
//

import UIKit
import CoreTableView

internal final class R_PassengerDataEntryController : UIViewController {
    
    private let nestedView = R_PassengerDataEntryView(frame: UIScreen.main.bounds)
    private var inputStates = [InputView.ViewState]()
    private var avaliableTariffs: [R_Tariff] = []
    private var additionalService : [R_Tariff: Int] = [:] {
        didSet {
            makeState()
        }
    }
    
    var setupUser: ((R_User, Int?, R_Trip) -> Void)?
    var model: R_Trip? {
        didSet {
            setupTariffType()
            if displayRiverUser == nil {
                firstSetup()
            }
        }
    }

    var displayRiverUser: R_User? {
        didSet {
            makeState()
        }
    }
    
    var index: Int?
            
    override func loadView() {
        super.loadView()
        view.backgroundColor = .custom(for: .base)
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRiverBackButton()
        title = "Пассажир"
    }
    
    private func setupTariffType() {
        guard let tariffs = model?.tarrifs else { return }
        tariffs.forEach { tariff in
            switch tariff.type {
            case .base, .default:
                avaliableTariffs.append(tariff)
            case .luggage, .good, .additional:
                additionalService.updateValue(0, forKey: tariff)
            }
        }
    }
    
    private func firstSetup() {
        var user = R_User()
        user.gender = .male
        displayRiverUser = user
    }
    
    private func makeState() {
        guard let user = displayRiverUser else { return }
        self.inputStates.removeAll()
        let tableState = createTableState(for: user)
        let onReadySelect = Command { [weak self] in
            self?.setupReadyButton()
        }
        let viewState = R_PassengerDataEntryView.ViewState(
            state: tableState,
            dataState: .loaded,
            onReadySelect: onReadySelect,
            validate: setupValidate()
        )
        self.nestedView.viewState = viewState
    }
    
    private func setupReadyButton() {
        guard var user = displayRiverUser else { return }
        user.ticket = nil
        SomeCache.shared.addToCache(user: user)
        self.popToBooking()
    }
    
    private func setupValidate() -> Bool {
        guard let user = displayRiverUser else { return false }
        let result: Bool = {
            user.name != nil &&
            user.surname != nil &&
            user.middleName != nil &&
            user.birthday != nil &&
            user.phoneNumber != nil &&
            user.gender != nil &&
            user.citizenShip != nil &&
            user.document != nil &&
            user.document?.cardIdentityNumber != nil &&
            user.ticket != nil
        }()
        return result
    }
    
    private func popToBooking() {
        guard
            let model = model,
            var user = displayRiverUser else { return }
        let additionalServicesCount = self.additionalService.reduce(0, { $0 + $1.value })
        
        if additionalServicesCount > 0 {
            var selectedServices: [R_AdditionService] = []
            for (service, itemsCount) in self.additionalService {
                if itemsCount > 0 {
                    let array = Array.init(repeating: service.toAdditionService(), count: itemsCount)
                    selectedServices.append(contentsOf: array)
                }
            }
            user.additionServices = selectedServices
        }
        setupUser?(user, index, model)
        navigationController?.popViewController(animated: true)
    }
    
    private func showPlaceController(for trip: R_Trip) {
        let controller = R_PlaceController()
        self.present(controller, animated: true) {
            controller.trip = trip
        }
    }
    
    private func handleOperation(for tariff: R_Tariff, isMinus: Bool) {
        switch tariff.type {
        case .base, .default:
            break
        case .luggage, .good, .additional:
            guard var currentCount = self.additionalService[tariff] else {
                return
            }
            if isMinus {
                currentCount -= 1
            } else {
                currentCount += 1
            }
            self.additionalService.updateValue(currentCount, forKey: tariff)
        }
    }
}

extension R_PassengerDataEntryController {
    
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
        let serialIsOnScreen = self.displayRiverUser?.document == nil ? 5 : 6
        let isLast = serialIsOnScreen == index
        
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
    
    private func createTableState(for user: R_User) -> [State] {
        guard let model = model else { return [] }
        var sections = [State]()
        let titleElement = R_PassengerDataEntryView.ViewState.Header(title: "Личные данные").toElement()
        var personalItems = [Element]()
        personalItems.append(titleElement)
        let onSurnameEnter: (TextEnterData) -> () = { data in
            self.displayRiverUser?.surname = data.text.isEmpty ? nil : data.text
        }
        let surnameState = self.createInputField(index: 1,
                                                 text: user.surname,
                                                 desc: "Фамилия",
                                                 placeholder: "Иванов",
                                                 keyboardType: .default,
                                                 onTextEnter: onSurnameEnter)
        self.inputStates.append(surnameState)
        
        let surnameField = R_PassengerDataEntryView.ViewState.Filed(
            text: user.surname == nil ? "Фамилия" : user.surname!,
            textColor: user.surname == nil ? .custom(for: .textSecondary) : .custom(for: .textPrimary)) {
            self.nestedView.showInput(with: surnameState)
        }.toElement()
        
        // name
        let onNameEnter: (TextEnterData) -> () = { data in
            self.displayRiverUser?.name = data.text.isEmpty ? nil : data.text
        }
        
        let nameState = self.createInputField(index: 2,
                                              text: user.name,
                                              desc: "Имя",
                                              placeholder: "Иван",
                                              keyboardType: .default,
                                              onTextEnter: onNameEnter)
        self.inputStates.append(nameState)
        
        let nameField = R_PassengerDataEntryView.ViewState.Filed(
            text: user.name == nil ? "Имя" : user.name!,
            textColor: user.name == nil ? .custom(for: .textSecondary) : .custom(for: .textPrimary)) {
            self.nestedView.showInput(with: nameState)
        }.toElement()
        
        // middle name
        let onMiddleNameEnter: (TextEnterData) -> () = { data in
            self.displayRiverUser?.middleName = data.text.isEmpty ? nil : data.text
        }
        
        let middleNameState = self.createInputField(index: 3,
                                                    text: user.middleName,
                                                    desc: "Отчество",
                                                    placeholder: "Иванович",
                                                    keyboardType: .default,
                                                    onTextEnter: onMiddleNameEnter)
        self.inputStates.append(middleNameState)
        
        let middleNameField = R_PassengerDataEntryView.ViewState.Filed(
            text: user.middleName == nil ? "Отчество" : user.middleName!,
            textColor: user.middleName == nil ? .custom(for: .textSecondary) : .custom(for: .textPrimary)) {
            self.nestedView.showInput(with: middleNameState)
        }.toElement()
        
        personalItems.append(contentsOf: [surnameField, nameField, middleNameField])
        let onBirthdayEnter: (TextEnterData) -> () = { data in
            self.displayRiverUser?.birthday = data.text.isEmpty ? nil : data.text
        }
        
        let validation: (TextValidationData) -> Bool = { [weak self] data in
            guard let validationData = self?.birtdayValidation(text: data.text, replacement: data.replacementString) else { return true }
            data.textField.text = validationData.0
            return validationData.1
        }
        
        let birthdayState = self.createInputField(index: 4,
                                                  text: user.birthday,
                                                  desc: "День рождения",
                                                  placeholder: "01.01.2000",
                                                  keyboardType: .numberPad,
                                                  onTextEnter: onBirthdayEnter,
                                                  validation: validation)
        
        self.inputStates.append(birthdayState)
        
        let birthdayField = R_PassengerDataEntryView.ViewState.Filed(
            text: user.birthday == nil ? "День рождения" : user.birthday!,
            textColor: user.birthday == nil ? .custom(for: .textSecondary) : .custom(for: .textPrimary)) {
            self.nestedView.showInput(with: birthdayState)
        }.toElement()
        personalItems.append(birthdayField)
        
        // phone
        let onPhoneEnter: (TextEnterData) -> () = { data in
            self.displayRiverUser?.phoneNumber = data.text.isEmpty ? nil : data.text
        }
        
        let phoneValidation: (TextValidationData) -> Bool = { [weak self] data in
            guard let validationData = self?.phoneValidation(text: data.text, replacement: data.replacementString) else { return true }
            data.textField.text = validationData.0
            return validationData.1
        }
        
        let phoneState = self.createInputField(index: 5,
                                               text: user.phoneNumber == nil ? "+7" : user.phoneNumber!,
                                               desc: "Телефон",
                                               placeholder: "+7 900 000 00 00",
                                               keyboardType: .numberPad,
                                               onTextEnter: onPhoneEnter,
                                               validation: phoneValidation)
        
        self.inputStates.append(phoneState)
        
        let phoneField = R_PassengerDataEntryView.ViewState.Filed(
            text: user.phoneNumber == nil ? "Телефон" : user.phoneNumber!,
            textColor: user.phoneNumber == nil ? .custom(for: .textSecondary) : .custom(for: .textPrimary)) {
            self.nestedView.showInput(with: phoneState)
        }.toElement()
        personalItems.append(phoneField)
        
        let genderField = R_PassengerDataEntryView.ViewState.GenderCell(gender: user.gender ?? .male, onTap: { gender in
            self.displayRiverUser?.gender = gender

        }).toElement()
        personalItems.append(genderField)
        
        let personalDataSectionState = SectionState(header: nil, footer: nil)
        sections.append(State(model: personalDataSectionState, elements: personalItems))
                
        let onCountrySelect = Command { [weak self] in
            let citizenshipController = R_CitizenshipController()
            citizenshipController.onCitizenshipSelect = Command<R_Citizenship> { [weak self] citizenship in
                self?.displayRiverUser?.citizenShip = citizenship
            }
            citizenshipController.modalPresentationStyle = .popover
            self?.present(citizenshipController, animated: true)
        }
            
        let countryTitle = R_PassengerDataEntryView.ViewState.Header(title: "Гражданство").toElement()
        let cTitle = (displayRiverUser?.citizenShip == nil ? "Указать гражданство" : displayRiverUser?.citizenShip!.name) ?? ""
        let countrySelection = R_PassengerDataEntryView.ViewState.SelectField(
            title: cTitle,
            onItemSelect: onCountrySelect
        ).toElement()
        let countrySection = SectionState(header: nil, footer: nil)
        let countryState = State(model: countrySection, elements: [countryTitle, countrySelection])
        sections.append(countryState)
        
        // documents
        var documentElements: [Element] = []
        let onDocSelect = Command { [weak self] in
            let documentController = R_DocumentController()
            documentController.tripId = model.id
            documentController.onDocumentSelect = Command<R_Document> { [weak self] document in
                self?.displayRiverUser?.document = document
            }
            self?.present(documentController, animated: true)
        }
        
        let docTitle = R_PassengerDataEntryView.ViewState.Header(title: "Документ").toElement()
        documentElements.append(docTitle)
        let dTitle = (displayRiverUser?.document == nil ? "Выбрать документ" : displayRiverUser?.document!.name) ?? ""
        let docSelection = R_PassengerDataEntryView.ViewState.SelectField(
            title: dTitle,
            onItemSelect: onDocSelect
        ).toElement()
        documentElements.append(docSelection)
        let docSection = SectionState(header: nil, footer: nil)
        if displayRiverUser?.document != nil {
            // show serial field
            let onSerialEnter: (TextEnterData) -> () = { data in
                self.displayRiverUser?.document?.cardIdentityNumber = data.text.isEmpty ? nil : data.text
            }
            
            let serailValidation: (TextValidationData) -> Bool = { [weak self] data in
                guard let validationData = self?.serialValidation(text: data.text, replacement: data.replacementString) else { return true }
                data.textField.text = validationData.0
                return validationData.1
            }
            
            let serialState = self.createInputField(index: 6,
                                                    text: user.document?.cardIdentityNumber == nil ? "" : user.document?.cardIdentityNumber,
                                                    desc: "Серия и номер",
                                                    placeholder: user.document?.exampleNumber ?? "",
                                                    keyboardType: .numberPad,
                                                    onTextEnter: onSerialEnter,
                                                    validation: serailValidation)
            
            self.inputStates.append(serialState)
            let serail = displayRiverUser?.document?.cardIdentityNumber
            let serailField = R_PassengerDataEntryView.ViewState.Filed(
                text: serail == nil ? "Введите данные" : serail!,
                textColor: user.document?.cardIdentityNumber == nil ? .custom(for: .textSecondary) : .custom(for: .textPrimary)) {
                self.nestedView.showInput(with: serialState)
            }.toElement()
            documentElements.append(serailField)
        }
        let docState = State(model: docSection, elements: documentElements)
        sections.append(docState)
        
        // tickets
        let tickets = R_PassengerDataEntryView.ViewState.Tickets(
            ticketList: avaliableTariffs,
            onChoice: { ticketIndex in
                let choiceTicket = self.avaliableTariffs[ticketIndex]
                self.displayRiverUser?.ticket = choiceTicket
            },
            selectedTicket: displayRiverUser?.ticket
        ).toElement()
        let ticketsHeader = R_PassengerDataEntryView.ViewState.TariffHeader(
            title: "Тариф",
            ticketsCount: 0,
            isInsetGroup: true
        )
        let ticketsSection = SectionState(header: ticketsHeader, footer: nil)
        let ticketsState = State(model: ticketsSection, elements: [tickets])
        sections.append(ticketsState)
        if displayRiverUser?.ticket != nil && !additionalService.isEmpty {
            let additionalHeader = R_PassengerDataEntryView.ViewState.TariffHeader(
                title: "Добавим к поездке?",
                ticketsCount: 0,
                isInsetGroup: true
            )
            var additionElements: [Element] = []
            for addition in additionalService {
                let tariff = addition.key
                let count = addition.value
                let price = "\(Int(tariff.price)) ₽"
                let onPlus = Command { [weak self] in
                    self?.handleOperation(for: tariff, isMinus: false)
                }
                var onMinus: Command<Void>?
                
                if count != 0 {
                    onMinus = Command { [weak self] in
                        self?.handleOperation(for: tariff, isMinus: true)
                    }
                }
                
                let tariffElement: Element = R_BookingWithoutPersonView.ViewState.TariffSteper(
                    height: 100,
                    serviceInfo: "ДОПОЛНИТЕЛЬНАЯ УСЛУГА",
                    tariff: tariff.name,
                    price: price,
                    stepperCount: "\(count)",
                    onPlus: onPlus,
                    onMinus: onMinus
                ).toElement()
                additionElements.append(tariffElement)
            }
            let additionalSection = SectionState(header: additionalHeader, footer: nil)
            let additionalState = State(model: additionalSection, elements: additionElements)
            sections.append(additionalState)
        }
        if !(displayRiverUser?.ticket?.isWithoutPlace ?? true) {
            let onSelect = Command { [weak self] in
                guard let self = self else { return }
                self.showPlaceController(for: model)
            }
            let choicePlace = R_BookingWithoutPersonView.ViewState.ChoicePlace(title: "Выберите место", onItemSelect: onSelect).toElement()
            let choiceSec = SectionState(header: nil, footer: nil)
            let choiceState = State(model: choiceSec, elements: [choicePlace])
            sections.append(choiceState)
        }
        return sections
    }
    
    private func serialValidation(text: String, replacement: String) -> (String, Bool) {
        if replacement == "" {
            return (text, true)
        }
        
        var _text = text
        if _text.count == 4 {
            _text.append(" ")
        }
        
        if _text.count >= 11 {
            return (_text, false)
        }
        
        return (_text, true)
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
