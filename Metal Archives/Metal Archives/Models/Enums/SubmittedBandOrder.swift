//
//  SubmittedBandOrder.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum SubmittedBandOrder: Int, CustomStringConvertible, CaseIterable {
    case bandAscending = 0, bandDescending, genreAscending, genreDescending, countryAscending, countryDescending, dateAscending, dateDescending
    
    var description: String {
        switch self {
        case .bandAscending: return "Band ascending ▲"
        case .bandDescending: return "Band descending ▼"
        case .genreAscending: return "Genre ascending ▲"
        case .genreDescending: return "Genre descending ▼"
        case .countryAscending: return "Country ascending ▲"
        case .countryDescending: return "Country descending ▼"
        case .dateAscending: return "Date ascending ▲"
        case .dateDescending: return "Date descending ▼"
        }
    }
    
    var options: [String: String] {
        let column: Int
        switch self {
        case .bandAscending, .bandDescending: column = 0
        case .genreAscending, .genreDescending: column = 1
        case .countryAscending, .countryDescending: column = 2
        case .dateAscending, .dateDescending: column = 3
        }
        
        let order: String
        switch self {
        case .bandAscending, .genreAscending, .countryAscending, .dateAscending: order = "asc"
        default: order = "desc"
        }
        
        return ["<SORT_COLUMN>": "\(column)", "<SORT_ORDER>": order]
    }
}
