//
//  _RiverStation.swift
//  
//
//  Created by polykuzin on 07/04/2022.
//

import Foundation

public protocol _RiverStation {
    var id: Int { get }
    var name: String { get }
    var cityID: Int { get }
    var cityName : String { get }
    var regionName: String { get }
    var countryID: Int { get }
    var countryName : String { get }
    var countryISO: String { get }
    var latitude : Double { get }
    var longitude: Double { get }
    var position: Int? { get }
    var onSelect : (() -> Void) { get }
}
