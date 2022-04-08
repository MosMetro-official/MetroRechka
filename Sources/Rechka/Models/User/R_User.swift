//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import CoreNetwork

// MARK: Gender

enum Gender: Int {
    case male = 1
    case female = 0
}

// MARK: - User
struct R_User: Equatable {
    
    var name: String?
    var surname: String?
    var middleName: String?
    var birthday: String?
    var phoneNumber: String?
    var mail: String?
    var citizenShip: R_Citizenship?
    var document: R_Document?
    var gender: Gender?
    var ticket: R_Tariff?
    
    init(ticket: R_Tariff) {
        self.ticket = ticket
    }
    
    init() { }
    
    func createBodyItem() -> [String: Any] {
        var resultingList = [String: Any]()
        if let name = name, let surname = surname {
            let middleNameStr = middleName == nil ? "" : " \(middleName!)"
            resultingList.updateValue("\(name) \(surname)\(middleNameStr)", forKey: "passengerName")
        }
        
        if let birthday = birthday {
            let separated = birthday.split(separator: ".")
            
            if let day = separated[safe: 0], let month = separated[safe: 1], let year = separated[safe: 2] {
                let newBirthdayString = "\(year)-\(month)-\(day)"
                resultingList.updateValue(newBirthdayString, forKey: "passengerBirthday")
            }
        }
        
        if let mail = mail {
            resultingList.updateValue(mail, forKey: "passengerEmail")
        }
        
        if let gender = gender {
            resultingList.updateValue(gender.rawValue, forKey: "passengerGender")
        }
        
        if let phoneNumber = phoneNumber {
            resultingList.updateValue(phoneNumber, forKey: "passengerPhone")
        }
        
        if let document = document {
            resultingList.updateValue(document.id, forKey: "cardIdentityId")
        }
        
        if let citizenShip = citizenShip {
            resultingList.updateValue(citizenShip.id, forKey: "citizenshipId")
        }
        
        resultingList.updateValue("auto", forKey: "position")
        
        if let ticket = ticket {
            resultingList.updateValue(ticket.id, forKey: "ticketTariffId")
            if ticket.isWithoutPlace {
                resultingList.updateValue("none", forKey: "position")
            } else {
                if let place = ticket.place {
                    resultingList.updateValue(place, forKey: "position")
                }
            }
        }
        
        //resultingList.updateValue([], forKey: "additionService")
        return resultingList
        
    }
}
