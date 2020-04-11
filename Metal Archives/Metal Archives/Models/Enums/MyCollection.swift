//
//  MyCollection.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum MyCollection: CustomStringConvertible {
    case collection, wanted, trade
    
    var description: String {
        switch self {
        case .collection: return "Album collection"
        case .wanted: return "Wanted list"
        case .trade: return "Trade list"
        }
    }
}
