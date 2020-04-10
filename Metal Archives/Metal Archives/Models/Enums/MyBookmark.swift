//
//  MyBookmark.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 10/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum MyBookmark: CustomStringConvertible {
    case bands, artists, labels, releases
    
    var description: String {
        switch self {
        case .bands: return "My bookmarks - Bands"
        case .artists: return "My bookmarks - Artists"
        case .labels: return "My bookmarks - Labels"
        case .releases: return "My bookmarks - Releases"
        }
    }
}
