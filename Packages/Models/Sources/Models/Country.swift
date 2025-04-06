//
//  Country.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/05/2021.
//

import Foundation

public struct Country: Sendable, Hashable {
    public let isoCode: String
    public let flag: String
    public let name: String

    public var nameAndFlag: String { "\(name) \(flag)" }
}

extension Country: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.isoCode < rhs.isoCode }

    public static func > (lhs: Self, rhs: Self) -> Bool { lhs.isoCode > rhs.isoCode }
}

extension Country: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool { lhs.isoCode == rhs.isoCode }
}

extension Country: Identifiable {
    public var id: String { isoCode }
}
