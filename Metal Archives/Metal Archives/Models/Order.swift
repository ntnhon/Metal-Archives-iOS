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

    var oppositeOrder: Order {
        switch self {
        case .ascending: return .descending
        case .descending: return .ascending
        }
    }

    var queryValue: String {
        switch self {
        case .ascending: return "asc"
        case .descending: return "desc"
        }
    }
}
