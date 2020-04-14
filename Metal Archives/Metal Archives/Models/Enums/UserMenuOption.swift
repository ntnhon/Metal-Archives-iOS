//
//  UserMenuOption.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 14/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum UserMenuOption: Int, CustomStringConvertible, CaseIterable {
    case reviews = 0, albumCollection, wantedList, tradeList, submittedBands, modificationHistory
    
    var description: String {
        switch self {
        case .reviews: return "Reviews"
        case .albumCollection: return "Album Collection"
        case .wantedList: return "Wanted List"
        case .tradeList: return "Trade List"
        case .submittedBands: return "Submitted Bands"
        case .modificationHistory: return "Modification History"
        }
    }
}
