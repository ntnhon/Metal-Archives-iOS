//
//  ArtistOrLabelBookmarkOrder.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum ArtistOrLabelBookmarkOrder: Int, CustomStringConvertible, CaseIterable {
    case nameAscending = 0, nameDescending, countryAscending, countryDescending, lastModifiedAscending, lastModifiedDescending, noteAscending, noteDescending
    
    var description: String {
        switch self {
        case .nameAscending: return "Name ascending ▲"
        case .nameDescending: return "Name descending ▼"
        case .countryAscending: return "Country ascending ▲"
        case .countryDescending: return "Country descending ▼"
        case .lastModifiedAscending: return "Last modification ascending ▲"
        case .lastModifiedDescending: return "Last modification descending ▼"
        case .noteAscending: return "Note ascending ▲"
        case .noteDescending: return "Note descending ▼"
        }
    }
    
    var options: [String: String] {
        let column: Int
        switch self {
        case .nameAscending, .nameDescending: column = 0
        case .countryAscending, .countryDescending: column = 1
        case .lastModifiedAscending, .lastModifiedDescending: column = 3
        case .noteAscending, .noteDescending: column = 4
        }
        
        let order: String
        switch self {
        case .nameAscending, .countryAscending, .lastModifiedAscending, .noteAscending: order = "asc"
        default: order = "desc"
        }
        
        return ["<SORT_COLUMN>": "\(column)", "<SORT_ORDER>": order]
    }
}
