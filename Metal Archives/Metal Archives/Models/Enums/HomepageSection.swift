//
//  HomepageSection.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 30/08/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum HomepageSection: Int, CustomStringConvertible, CaseIterable {
    case statistics = 0, upcomingAlbums, latestAdditions, latestUpdates, latestReviews, newsArchives
    
    var description: String {
        switch self {
        case .statistics: return "Statistics"
        case .upcomingAlbums: return "Upcoming Albums"
        case .latestAdditions: return "Latest Additions"
        case .latestUpdates: return "Latest Updates"
        case .latestReviews: return "Latest Reviews"
        case .newsArchives: return "News Archives"
        }
    }
}
