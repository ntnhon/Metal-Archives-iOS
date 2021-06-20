//
//  HomeSection.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import Foundation

// swiftlint:disable explicit_enum_raw_value
enum HomeSection: Int, CustomStringConvertible, Codable {
    case stats = 0, news, upcomingAlbums, latestAdditions, latestUpdates, latestReviews

    var description: String {
        switch self {
        case .stats: return "Statistics"
        case .news: return "News Archives"
        case .upcomingAlbums: return "Upcoming Albums"
        case .latestAdditions: return "Latest Additions"
        case .latestUpdates: return "Latest Updates"
        case .latestReviews: return "Latest Reviews"
        }
    }
}
