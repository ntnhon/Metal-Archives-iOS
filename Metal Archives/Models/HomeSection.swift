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
        case .upcomingAlbums:
            "Upcoming Albums"
        case .latestAdditions:
            "Latest Additions"
        case .latestUpdates:
            "Latest Updates"
        case .latestReviews:
            "Latest Reviews"
        }
    }
}

extension HomeSection: Identifiable {
    var id: Int { rawValue }
}
