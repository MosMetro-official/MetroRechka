//
//  fake.swift
//  
//
//  Created by Слава Платонов on 13.03.2022.
//

import Foundation

class SomeCache {
    static let shared = SomeCache()
    private init() {}
    var cache: [String: [User]] = ["user": []]
    
    func replaceUser(on user: User) {
        guard var users = cache["user"] else { return }
        for (index, _) in users.enumerated() {
            users[index] = user
        }
    }
   
    func checkCache(for user: User) -> Bool {
        guard let users = cache["user"] else { return false }
        if users.contains(user) {
            return false
        }
        return true
    }
    
    func addToCache(user: User) {
        cache["user"]?.append(user)
    }
}

struct PaymentModel {
    var ticket: [Ticket]
}

struct Ticket {
    var user: User?
    var ticket: FakeTickets?
}

struct User: Equatable {
    var name: String?
    var surname: String?
    var middleName: String?
    var birthday: String?
    var phoneNumber: String?
    var gender: Gender?
}

enum Gender: String {
    case male
    case female
}

struct FakeTickets {
    let price: String
    let tariff: String
    //var user: User?
}

struct FakeModel: Equatable {
    static func == (lhs: FakeModel, rhs: FakeModel) -> Bool {
        return lhs.title == rhs.title
    }
    let title: String
    let jetty: String
    let time: String
    let tickets: Bool
    let price: String
    let duration: String
    let fromTo: String
    var ticketsList: [FakeTickets]
    let ticketsCount: Int
    let isPersonalDataRequired: Bool
    let isWithoutPlace: Bool
    let places: [String]
    
    static func getModels() -> [FakeModel] {
        let first = FakeModel(
            title: "Круиз «Рэдиссон» ресторана «ERWIN.Река»",
            jetty: "Причал Зарядье",
            time: "1 час",
            tickets: true,
            price: "700 ₽",
            duration: "22 марта 13:00 • 2 часа • 15 км",
            fromTo: "От Холмогорская улица до АС Бронницы",
            ticketsList: [
                FakeTickets(price: "700 ₽", tariff: "Детский (с ужином или обедом, Standard)"),
                FakeTickets(price: "1000 ₽", tariff: "Детский (с ужином или обедом, Premium)"),
                FakeTickets(price: "1100 ₽", tariff: "Взрослый (с ужином или обедом, Standard)"),
                FakeTickets(price: "1500 ₽", tariff: "Взрослый (с ужином или обедом, Premium)")
            ],
            ticketsCount: 6,
            isPersonalDataRequired: true,
            isWithoutPlace: false,
            places: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        )
        let second = FakeModel(
            title: "Экскурсия",
            jetty: "Причал Мост Багратион",
            time: "3 часа",
            tickets: false,
            price: "1500 ₽",
            duration: "22 марта 13:00 • 2 часа • 15 км",
            fromTo: "От Холмогорская улица до АС Бронницы",
            ticketsList: [FakeTickets(price: "1500 ₽", tariff: "Единый")],
            ticketsCount: 2,
            isPersonalDataRequired: false,
            isWithoutPlace: true,
            places: []
        )
        let third = FakeModel(
            title: "Круиз «Filmonter» ресторана «METRO»",
            jetty: "Причал Мост Багратион",
            time: "2 часа",
            tickets: true,
            price: "1200 ₽",
            duration: "22 марта 13:00 • 2 часа • 15 км",
            fromTo: "От Холмогорская улица до АС Бронницы",
            ticketsList: [
                FakeTickets(price: "1200 ₽", tariff: "Детский (с ужином или обедом, Standard)"),
                FakeTickets(price: "1300 ₽", tariff: "Детский (с ужином или обедом, Premium)"),
                FakeTickets(price: "1500 ₽", tariff: "Взрослый (с ужином или обедом, Standard)"),
                FakeTickets(price: "1800 ₽", tariff: "Взрослый (с ужином или обедом, Premium)")
            ],
            ticketsCount: 2,
            isPersonalDataRequired: false,
            isWithoutPlace: false,
            places: ["1", "2", "3", "4", "5"]
        )
        let fourth = FakeModel(
            title: "Экскурсия",
            jetty: "Причал Мост Багратион",
            time: "4 часа",
            tickets: false,
            price: "1900 ₽",
            duration: "22 марта 13:00 • 2 часа • 15 км",
            fromTo: "От Холмогорская улица до АС Бронницы",
            ticketsList: [FakeTickets(price: "1900 ₽", tariff: "Единый")],
            ticketsCount: 0,
            isPersonalDataRequired: false,
            isWithoutPlace: true,
            places: []
        )
        let fiveth = FakeModel(
            title: "Круиз «Рэдиссон» ресторана «ERWIN.Река»",
            jetty: "Причал Зарядье",
            time: "2 часа",
            tickets: false,
            price: "900 ₽",
            duration: "22 марта 13:00 • 2 часа • 15 км",
            fromTo: "От Холмогорская улица до АС Бронницы",
            ticketsList: [
                FakeTickets(price: "900 ₽", tariff: "Детский"),
                FakeTickets(price: "1300 ₽", tariff: "Взрослый")
            ],
            ticketsCount: 4,
            isPersonalDataRequired: true,
            isWithoutPlace: true,
            places: []
        )
        let sixth = FakeModel(
            title: "Экскурсия",
            jetty: "Причал Мост Багратион",
            time: "4 часа",
            tickets: false,
            price: "1100 ₽",
            duration: "22 марта 13:00 • 2 часа • 15 км",
            fromTo: "От Холмогорская улица до АС Бронницы",
            ticketsList: [FakeTickets(price: "1100 ₽", tariff: "Единый")],
            ticketsCount: 12,
            isPersonalDataRequired: false,
            isWithoutPlace: true,
            places: []
        )
        let seventh = FakeModel(
            title: "Круиз «Рэдиссон» ресторана «ERWIN.Река",
            jetty: "Причал Мост Багратион",
            time: "3 часа",
            tickets: false,
            price: "1900 ₽",
            duration: "22 марта 13:00 • 2 часа • 15 км",
            fromTo: "От Холмогорская улица до АС Бронницы",
            ticketsList: [
                FakeTickets(price: "1900 ₽", tariff: "Детский"),
                FakeTickets(price: "2100 ₽", tariff: "Взрослый")
            ],
            ticketsCount: 2,
            isPersonalDataRequired: true,
            isWithoutPlace: true,
            places: []
        )
        let eighth = FakeModel(
            title: "Экскурсия",
            jetty: "Причал Мост Багратион",
            time: "1 час",
            tickets: true,
            price: "800 ₽",
            duration: "22 марта 13:00 • 2 часа • 15 км",
            fromTo: "От Холмогорская улица до АС Бронницы",
            ticketsList: [FakeTickets(price: "800 ₽", tariff: "Единый")],
            ticketsCount: 0,
            isPersonalDataRequired: false,
            isWithoutPlace: true,
            places: []
        )
        return [first, second, third, fourth, fiveth, sixth, seventh, eighth]
    }
}


