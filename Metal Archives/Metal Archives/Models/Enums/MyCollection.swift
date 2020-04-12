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
    
    var listDescription: String {
        switch self {
        case .collection: return "album collection"
        case .wanted: return "wanted list"
        case .trade: return "trade list"
        }
    }
    
    var urlParam: String {
        switch self {
        case .collection: return "collection"
        case .wanted: return "wanted"
        case .trade: return "trade"
        }
    }
    
    var addOrRemoveParam: String {
        switch self {
        case .collection: return "1"
        case .wanted: return "3"
        case .trade: return "2"
        }
    }
}
