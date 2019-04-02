//
//  AdditionOrUpdateType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum AdditionOrUpdateType: Int, CustomStringConvertible, CaseIterable {
    case bands = 0, labels, artists
    
    var description: String {
        switch self {
        case .bands: return "Bands"
        case .labels: return "Labels"
        case .artists: return "Artists"
        }
    }
}
