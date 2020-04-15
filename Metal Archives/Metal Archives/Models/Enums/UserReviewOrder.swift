//
//  UserReviewOrder.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum UserReviewOrder: Int, CustomStringConvertible, CaseIterable {
    case dateAscending = 0, dateDescending, bandAscending, bandDescending, releaseAscending, releaseDescending, titleAscending, titleDescending, ratingAscending, ratingDescending
    
    var description: String {
        switch self {
        case .dateAscending: return "Date ascending ▲"
        case .dateDescending: return "Date descending ▼"
        case .bandAscending: return "Band ascending ▲"
        case .bandDescending: return "Band descending ▼"
        case .releaseAscending: return "Release ascending ▲"
        case .releaseDescending: return "Release descending ▼"
        case .titleAscending: return "Title ascending ▲"
        case .titleDescending: return "Title descending ▼"
        case .ratingAscending: return "Rating ascending ▲"
        case .ratingDescending: return "Rating descending ▼"
        }
    }
    
    var options: [String: String] {
        let column: Int
        switch self {
        case .dateAscending, .dateDescending: column = 1
        case .bandAscending, .bandDescending: column = 2
        case .releaseAscending, .releaseDescending: column = 3
        case .titleAscending, .titleDescending: column = 4
        case .ratingAscending, .ratingDescending: column = 5
        }
        
        let order: String
        switch self {
        case .dateAscending, .bandAscending, .releaseAscending, .titleAscending, .ratingAscending: order = "asc"
        default: order = "desc"
        }
        
        return ["<SORT_COLUMN>": "\(column)", "<SORT_ORDER>": order]
    }
}
