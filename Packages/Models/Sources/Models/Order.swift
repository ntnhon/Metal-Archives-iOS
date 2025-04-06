//
//  Order.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/07/2021.
//

import Foundation

public enum Order: Int, Sendable, CaseIterable {
    case ascending
    case descending

    public var oppositeOrder: Self {
        switch self {
        case .ascending:
            .descending
        case .descending:
            .ascending
        }
    }

    public var queryValue: String {
        switch self {
        case .ascending:
            "asc"
        case .descending:
            "desc"
        }
    }

    public var title: String {
        switch self {
        case .ascending:
            "Ascending ↑"
        case .descending:
            "Descending ↓"
        }
    }
}
