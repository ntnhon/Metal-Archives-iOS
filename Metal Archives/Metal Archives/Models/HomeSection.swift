//
//  HomeSection.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import Foundation

enum HomeSection: Int, CustomStringConvertible, Codable {
    case upcomingAlbums, latestAdditions, latestUpdates, latestReviews

    var description: String {
        switch self {
        case .upcomingAlbums: return "Upcoming Albums"
        case .latestAdditions: return "Latest Additions"
        case .latestUpdates: return "Latest Updates"
        case .latestReviews: return "Latest Reviews"
        }
    }
}
