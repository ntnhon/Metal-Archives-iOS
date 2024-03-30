//
//  Order.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 09/07/2021.
//

import Foundation

enum Order: Int {
    case ascending
    case descending

    var oppositeOrder: Self {
        switch self {
        case .ascending:
            .descending
        case .descending:
            .ascending
        }
    }

    var queryValue: String {
        switch self {
        case .ascending:
            "asc"
        case .descending:
            "desc"
        }
    }
}
