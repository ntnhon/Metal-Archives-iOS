//
//  Country.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/05/2021.
//

import Foundation

struct Country {
    let isoCode: String
    let flag: String
    let name: String

    var nameAndFlag: String { "\(name) \(flag)" }
}

extension Country: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.isoCode < rhs.isoCode }

    static func > (lhs: Self, rhs: Self) -> Bool { lhs.isoCode > rhs.isoCode }
}

extension Country: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.isoCode == rhs.isoCode }
}

extension Country: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(isoCode)
    }
}

extension Country: Identifiable {
    var id: String { isoCode }
}

extension Country: MultipleChoiceProtocol {
    static var noChoice: String { "Any country" }
    static var multipleChoicesSuffix: String { "countries selected" }
    static var totalChoices: Int { CountryManager.shared.countries.count }
    var choiceDescription: String { nameAndFlag }
}

final class CountrySet: MultipleChoiceSet<Country>, ObservableObject {}

extension Country {
    static var usa: Country {
        .init(isoCode: "US", flag: "🇺🇸", name: "United States")
    }

    static var unknown: Country {
        .init(isoCode: "ZZ", flag: "🏳️", name: "Unknown")
    }
}
