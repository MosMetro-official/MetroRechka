//
//  Custom dateformatters.swift
//  MetroRechka
//
//  Created by guseyn on 15.07.2022.
//

import Foundation

extension DateFormatter {
  static let river: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter
  }()
}
