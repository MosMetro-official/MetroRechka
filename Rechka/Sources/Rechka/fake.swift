//
//  fake.swift
//  
//
//  Created by Слава Платонов on 13.03.2022.
//

import Foundation

struct FakeModel {
    let title: String
    let jetty: String
    let time: String
    let tickets: Bool
    let price: String
    
    static func getModels() -> [FakeModel] {
        let first = FakeModel(
            title: "Круиз «Рэдиссон» ресторана «ERWIN.Река»",
            jetty: "Причал Зарядье",
            time: "1 час",
            tickets: true,
            price: "700 ₽"
        )
        let second = FakeModel(
            title: "Экскурсия",
            jetty: "Причал Мост Багратион",
            time: "3 часа",
            tickets: false,
            price: "1500 ₽"
        )
        let third = FakeModel(
            title: "Круиз «Filmonter» ресторана «METRO»",
            jetty: "Причал Мост Багратион",
            time: "2 часа",
            tickets: true,
            price: "1200 ₽"
        )
        let fourth = FakeModel(
            title: "Экскурсия",
            jetty: "Причал Мост Багратион",
            time: "4 часа",
            tickets: false,
            price: "1900 ₽"
        )
        let fiveth = FakeModel(
            title: "Круиз «Рэдиссон» ресторана «ERWIN.Река»",
            jetty: "Причал Зарядье",
            time: "2 часа",
            tickets: false,
            price: "900 ₽"
        )
        let sixth = FakeModel(
            title: "Экскурсия",
            jetty: "Причал Мост Багратион",
            time: "4 часа",
            tickets: false,
            price: "1100 ₽"
        )
        let seventh = FakeModel(
            title: "Круиз «Рэдиссон» ресторана «ERWIN.Река",
            jetty: "Причал Мост Багратион",
            time: "3 часа",
            tickets: false,
            price: "1900 ₽"
        )
        let eighth = FakeModel(
            title: "Экскурсия",
            jetty: "Причал Мост Багратион",
            time: "1 час",
            tickets: true,
            price: "800 ₽"
        )
        return [first, second, third, fourth, fiveth, sixth, seventh, eighth]
    }
}


