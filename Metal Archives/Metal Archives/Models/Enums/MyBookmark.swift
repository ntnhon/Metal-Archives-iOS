//
//  MyBookmark.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 10/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum BookmarkAction: String {
    case add = "add", remove = "remove"
}

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
    
    var shortDescription: String {
        switch self {
        case .bands: return "band"
        case .labels: return "label"
        case .artists: return "artist"
        case .releases: return "release"
        }
    }
    
    var param: Int {
        switch self {
        case .bands: return 1
        case .artists: return 3
        case .labels: return 2
        case .releases: return 4
        }
    }
}
