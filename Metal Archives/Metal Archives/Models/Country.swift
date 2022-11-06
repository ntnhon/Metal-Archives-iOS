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

final class CountrySet: ObservableObject {
    @Published var countries: [Country] = []

    var detailString: String {
        if countries.isEmpty {
            return "Any country"
        } else {
            return countries.map { $0.name }.joined(separator: ", ")
        }
    }
}

extension Country {
    static var usa: Country {
        .init(isoCode: "US", flag: "🇺🇸", name: "United States")
    }

    static var unknown: Country {
        .init(isoCode: "ZZ", flag: "🏳️", name: "Unknown")
    }
}
