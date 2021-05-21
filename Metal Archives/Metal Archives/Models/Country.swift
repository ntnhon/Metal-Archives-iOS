//
//  Country.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/05/2021.
//

import Foundation

struct Country {
    let isoCode: String
    let emoji: String
    let name: String

    var nameAndEmoji: String { "\(name) \(emoji)" }
}

extension Country: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.isoCode < rhs.isoCode }

    static func > (lhs: Self, rhs: Self) -> Bool { lhs.isoCode > rhs.isoCode }
}

extension Country: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.isoCode == rhs.isoCode }
}
