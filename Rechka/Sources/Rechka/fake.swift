//
//  fake.swift
//  
//
//  Created by Слава Платонов on 13.03.2022.
//

import Foundation

struct FakeTickets {
    let price: String
    let tariff: String
}

struct FakeModel {
    let title: String
    let jetty: String
    let time: String
    let tickets: Bool
    let price: String
    let duration: String
    let fromTo: String
    let ticketsList: [FakeTickets]
    let ticketsCount: Int
    
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
            ticketsCount: 6
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
            ticketsCount: 2
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
            ticketsCount: 2
        )
        let fourth = FakeModel(
            title: "Экскурсия",
            jetty: "Причал Мост Багратион",
            time: "4 часа",
            tickets: false,
            price: "1900 ₽",
            duration: "22 марта 13:00 • 2 часа • 15 км",
            fromTo: "От Холмогорская улица до АС Бронницы",
            ticketsList: [FakeTickets(price: "1900 ₽", tariff: "Единый")], ticketsCount: 0
        )
        let fiveth = FakeModel(
            title: "Круиз «Рэдиссон» ресторана «ERWIN.Река»",
            jetty: "Причал Зарядье",
            time: "2 часа",
            tickets: false,
            price: "900 ₽",
            duration: "22 марта 13:00 • 2 часа • 15 км",
            fromTo: "От Холмогорская улица до АС Бронницы",
            ticketsList: [FakeTickets(price: "900 ₽", tariff: "Детский"), FakeTickets(price: "1300 ₽", tariff: "Взрослый")],
            ticketsCount: 4
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
            ticketsCount: 12
        )
        let seventh = FakeModel(
            title: "Круиз «Рэдиссон» ресторана «ERWIN.Река",
            jetty: "Причал Мост Багратион",
            time: "3 часа",
            tickets: false,
            price: "1900 ₽",
            duration: "22 марта 13:00 • 2 часа • 15 км",
            fromTo: "От Холмогорская улица до АС Бронницы",
            ticketsList: [FakeTickets(price: "1900 ₽", tariff: "Детский"), FakeTickets(price: "2100 ₽", tariff: "Взрослый")],
            ticketsCount: 2
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
            ticketsCount: 0
        )
        return [first, second, third, fourth, fiveth, sixth, seventh, eighth]
    }
}


