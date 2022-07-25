//
//  File.swift
//  
//
//  Created by guseyn on 08.04.2022.
//

import Foundation
import MMCoreNetworkAsync


// MARK: Book Request

struct R_BookRequest: Encodable {
    public let users: [R_User]
    private let returnURL: String = Rechka.shared.returnURL
    private let failURL: String = Rechka.shared.failURL
    public let tripID: Int
    
    init(users: [R_User], tripID: Int) {
        self.users = users
        self.tripID = tripID
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case returnUrl
        case failUrl
        case tickets
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tripID, forKey: .id)
        try container.encode(users, forKey: .tickets)
        try container.encode(returnURL, forKey: .returnUrl)
        try container.encode(failURL, forKey: .failUrl)
        
    }
    
}

// MARK: Gender

enum Gender: Int, Encodable, Decodable {
    case male = 1
    case female = 0
}

// MARK: - User
struct R_User: Equatable, Codable {
    var id = UUID().uuidString
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
    var additionServices: [R_AdditionService]?
    
    var data: Data {
        guard let data = try? JSONEncoder().encode(self) else { return Data() }
        return data
    }
    
    var key: String {
        guard let name = name, let surname = surname, let gender = gender?.rawValue else { return "" }
        return "\(name)-\(surname)-\(gender)"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: R_User.CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        let fullName = try values.decode(String.self, forKey: .passengerName).components(separatedBy: " ")
        if let name = fullName[safe: 0], let middleName = fullName[safe: 1], let surname = fullName[safe: 2] {
            self.name = "\(name)"
            self.middleName = "\(middleName)"
            self.surname = "\(surname)"
        }
        
        let birthday = try values.decode(String.self, forKey: .passengerBirthday).components(separatedBy: "-")
        if let day = birthday[safe: 0], let month = birthday[safe: 1], let year = birthday[safe: 2] {
            self.birthday = "\(day).\(month).\(year)"
        }
        
        gender = try values.decode(Gender.self, forKey: .passengerGender)
        
        self.phoneNumber = try values.decode(String.self, forKey: .cachePhone)
        
        document = try values.decode(R_Document.self, forKey: .document)
        citizenShip = try values.decode(R_Citizenship.self, forKey: .citizenship)
        ticket = nil
        additionServices = nil
        mail = nil
    }
    
    init?(data: Data) {
        guard let user = try? JSONDecoder().decode(R_User.self, from: data) else { return nil }
        self = user
    }
    
    init(ticket: R_Tariff) {
        self.ticket = ticket
    }
    
    init() { }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case passengerName
        case passengerBirthday
        case passengerEmail
        case passengerGender
        case passengerPhone
        case cachePhone
        case cardIdentityId
        case cardIdentityNumber
        case citizenshipId
        case ticketTariffId
        case position
        case additionService
        case document
        case citizenship
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        let fullName = [name,middleName,surname].compactMap { $0 }.joined(separator: " ")
        if !fullName.isEmpty {
            try container.encode(fullName, forKey: .passengerName)
        }
        
        if let birthday = birthday {
            let separated = birthday.split(separator: ".")
            
            if let day = separated[safe: 0], let month = separated[safe: 1], let year = separated[safe: 2] {
                let newBirthdayString = "\(day)-\(month)-\(year)"
                try container.encode(newBirthdayString, forKey: .passengerBirthday)
            }
        }
        
        try container.encodeIfPresent(mail, forKey: .passengerEmail)
        try container.encodeIfPresent(gender, forKey: .passengerGender)
        if var phoneNumber = phoneNumber {
            phoneNumber = phoneNumber.replacingOccurrences(of: "+", with: "")
            phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
            try container.encode(phoneNumber, forKey: .passengerPhone)
        }
        try container.encode(phoneNumber, forKey: .cachePhone)
        
        
        if let document = document, let cardIdentityNumber = document.cardIdentityNumber {
            try container.encode(document, forKey: .document)
            try container.encode(document.id, forKey: .cardIdentityId)
            try container.encode(cardIdentityNumber, forKey: .cardIdentityNumber)
        }
        
        try container.encodeIfPresent(citizenShip?.id, forKey: .citizenshipId)
        try container.encodeIfPresent(citizenShip, forKey: .citizenship)
        if let ticket = ticket {
            try container.encode(ticket.id, forKey: .ticketTariffId)
            if ticket.isWithoutPlace {
                try container.encode("none", forKey: .position)
            } else {
                try container.encode(ticket.place == nil ? "auto" : "\(ticket.place!)", forKey: .position)
            }
        } else {
            try container.encode("auto" , forKey: .position)
        }
        
        try container.encodeIfPresent(additionServices, forKey: .additionService)
        
    }
    
//    func createBodyItem() -> [String: Any] {
//        var resultingList = [String: Any]()
//        if let name = name, let surname = surname {
//            let middleNameStr = middleName == nil ? "" : " \(middleName!)"
//            resultingList.updateValue("\(name) \(surname) \(middleNameStr)", forKey: "passengerName")
//        }
//
//        if let birthday = birthday {
//            let separated = birthday.split(separator: ".")
//
//            if let day = separated[safe: 0], let month = separated[safe: 1], let year = separated[safe: 2] {
//                let newBirthdayString = "\(year)-\(month)-\(day)"
//                resultingList.updateValue(newBirthdayString, forKey: "passengerBirthday")
//            }
//        }
//
//        if let mail = mail {
//            resultingList.updateValue(mail, forKey: "passengerEmail")
//        }
//
//        if let gender = gender {
//            resultingList.updateValue(gender.rawValue, forKey: "passengerGender")
//        }
//
//        if var phoneNumber = phoneNumber {
//            phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
//            phoneNumber = phoneNumber.replacingOccurrences(of: "+", with: "")
//            resultingList.updateValue(phoneNumber, forKey: "passengerPhone")
//        }
//
//        if let document = document, let cardIdentityNumber = document.cardIdentityNumber {
//            resultingList.updateValue(document.id, forKey: "cardIdentityId")
//            resultingList.updateValue(cardIdentityNumber, forKey: "cardIdentityNumber")
//        }
//
//        if let citizenShip = citizenShip {
//            resultingList.updateValue(citizenShip.id, forKey: "citizenshipId")
//        }
//
//        resultingList.updateValue("auto", forKey: "position")
//
//        if let ticket = ticket {
//            resultingList.updateValue(ticket.id, forKey: "ticketTariffId")
//            if ticket.isWithoutPlace {
//                resultingList.updateValue("none", forKey: "position")
//            } else {
//                if let place = ticket.place {
//                    resultingList.updateValue(place, forKey: "position")
//                }
//            }
//        }
//        if let additionServices = additionServices {
//            let grouped = Dictionary(grouping: additionServices, by: { $0 })
//            let additions: [[String:Any]] = grouped.map { key, value in
//                return ["id": key.id,
//                        "name": key.name_ru,
//                        "nameEn": key.name_en,
//                        "type": key.type,
//                        "pricePerOne": key.price,
//                        "count": value.count,
//                        "priceTotal": key.price * Double(value.count)
//                ]
//            }
//
//            resultingList.updateValue(additions, forKey: "additionService")
//
//
//        }
//
//        return resultingList
//
//    }
}
