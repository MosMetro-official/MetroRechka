//
//  File.swift
//  
//
//  Created by Слава Платонов on 10.03.2022.
//

import Foundation

// MARK: - Flights
struct Flights: Codable {
    let success: Bool
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let trips, similarTrips: [Trip]
}

// MARK: - Trip
struct Trip: Codable {
    let id, vendorID, actualFlag: Int
    let routeName: String
    let distance, freePlaceCount, buyPlaceCountMax, vendorCurrencyID: Int
    let vendorTicketPrice, agentCurrencyID, ticketPrice, agentFee: Int
    let agentTicketPriceMax: Int
    let dateTimeStart, dateTimeEnd, planDateTimeStart, planDateTimeEnd: String
    let stationStart, stationEnd: Station
    let vehicle: Vehicle
    let transportCompanyName: String

    enum CodingKeys: String, CodingKey {
        case id
        case vendorID = "vendorId"
        case actualFlag, routeName, distance, freePlaceCount, buyPlaceCountMax
        case vendorCurrencyID = "vendorCurrencyId"
        case vendorTicketPrice
        case agentCurrencyID = "agentCurrencyId"
        case ticketPrice, agentFee, agentTicketPriceMax, dateTimeStart, dateTimeEnd, planDateTimeStart, planDateTimeEnd, stationStart, stationEnd, vehicle, transportCompanyName
    }
}

// MARK: - Station
struct Station: Codable {
    let id: Int
    let name: String
    let cityID: Int
    let cityName, regionName, districtName: String
    let countryID: Int
    let countryName, countryISO: String
    let lat, lon: Int

    enum CodingKeys: String, CodingKey {
        case id, name
        case cityID = "cityId"
        case cityName, regionName, districtName
        case countryID = "countryId"
        case countryName, countryISO, lat, lon
    }
}

// MARK: - Vehicle
struct Vehicle: Codable {
    let name, number: String
    let placeCount, airConditioningFlag, tvFlag: Int

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case number = "Number"
        case placeCount = "PlaceCount"
        case airConditioningFlag = "AirConditioningFlag"
        case tvFlag = "TvFlag"
    }
}
