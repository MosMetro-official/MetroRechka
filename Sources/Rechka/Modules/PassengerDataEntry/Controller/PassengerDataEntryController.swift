//
//  PassengerDataEntryController.swift
//  
//
//  Created by Слава Платонов on 23.03.2022.
//

import UIKit
import CoreTableView

class PassengerDataEntryController: UIViewController {
    
    weak var delegate: PersonBookingDelegate?
    let nestedView = PassengerDataEntryView(frame: UIScreen.main.bounds)
    var model: FakeModel!
    var user = User(name: nil, surname: nil, patronymic: nil, birthday: nil, phoneNumber: nil, gender: .male) {
        didSet {
            setupValidate()
        }
    }
    
    override func loadView() {
        super.loadView()
        view = nestedView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeState()
        setupReadyButton()
        dismissKeyboard()
        title = "Пассажир"
    }
    
    func makeState() {
        let personDataHeader = PassengerDataEntryView.ViewState.PersonHeader(title: "Личные данные", height: 40).toElement()
        let surname = PassengerDataEntryView.ViewState.SurnameField(placeholder: "Фамилия", onTap: {}, onFieldEdit: {
            textfield in
            self.user.surname = textfield.text
        }, height: 40).toElement()
        let name = PassengerDataEntryView.ViewState.NameField(placeholder: "Имя", onTap: {}, onFieldEdit: { textfield in
            self.user.name = textfield.text
        }, height: 40).toElement()
        let patronymic = PassengerDataEntryView.ViewState.PatronymicFiled(placeholder: "Отчество", onTap: {}, onFieldEdit: { textfield in
            self.user.patronymic = textfield.text
        }, height: 40).toElement()
        let birthday = PassengerDataEntryView.ViewState.BirthdayField(placeholder: "День рождения", textFieldType: .numberPad, onTap: {}, onFieldEdit: { textfield in
            self.user.birthday = textfield.text
        } ,height: 40).toElement()
        let number = PassengerDataEntryView.ViewState.NumberFiled(placeholder: "Телефон", textFieldType: .numberPad, onTap: {}, onFieldEdit: { textfield in
            self.user.phoneNumber = textfield.text
        }, height: 40).toElement()
        let gender = PassengerDataEntryView.ViewState.GenderCell(gender: .male, onTap: { gender in
            self.user.gender = gender
        }, height: 50).toElement()
        let personSection = SectionState(header: nil, footer: nil)
        let personState = State(model: personSection, elements: [personDataHeader, surname, name, patronymic, birthday, number, gender])
        
        let citizenHeader = PassengerDataEntryView.ViewState.CitizenshipHeader(title: "Гражданство", height: 50).toElement()
        let citizenship = PassengerDataEntryView.ViewState.CitizenshipCell(title: "Указать гражданство", onSelect: {}, height: 50).toElement()
        let citizenshipSection = SectionState(header: nil, footer: nil)
        let citizenshipState = State(model: citizenshipSection, elements: [citizenHeader, citizenship])
        
        let documentHeader = PassengerDataEntryView.ViewState.DocumentHeader(title: "Документ", height: 50).toElement()
        let document = PassengerDataEntryView.ViewState.DocumentCell(title: "Выбрать документ", onSelect: {}, height: 50).toElement()
        let documentSection = SectionState(header: nil, footer: nil)
        let documentState = State(model: documentSection, elements: [documentHeader, document])
        
        nestedView.viewState.state = [personState, citizenshipState, documentState]
    }
    
    private func setupReadyButton() {
        nestedView.onReadySelect = { [weak self] in
            guard let self = self else { return }
            SomeCache.shared.addToCache(user: self.user)
            self.popToBooking()
        }
    }
    
    private func popToBooking() {
        delegate?.setupNewUser(for: user, and: model)
        navigationController?.popViewController(animated: true)
    }
    
    private func setupValidate() {
        nestedView.validate = {
            if self.user.surname != nil && self.user.name != nil && self.user.patronymic != nil {
                return true
            }
            return false
        }
    }
    
}

