//
//  WidgetSection.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum WidgetSection: Int, CustomStringConvertible, CaseIterable {
    case bandAdditions = 0, bandUpdates, latestReviews, upcomingAlbums
    
    var description: String {
        switch self {
        case .bandAdditions: return "Band additions"
        case .bandUpdates: return "Band updates"
        case .latestReviews: return "Latest reviews"
        case .upcomingAlbums: return "Upcoming albums"
        }
    }
    
    var headerTitle: String {
        switch self {
        case .bandAdditions: return "Recently added bands"
        case .bandUpdates: return "Recently updated bands"
        case .latestReviews: return "Latest reviews"
        case .upcomingAlbums: return "Upcoming albums"
        }
    }
}
