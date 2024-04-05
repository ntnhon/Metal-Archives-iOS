//
//  HomeSection.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 20/06/2021.
//

import Foundation

public enum HomeSection: Int, Sendable, CustomStringConvertible, Codable {
    case upcomingAlbums, latestAdditions, latestUpdates, latestReviews

    public var description: String {
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
    public var id: Int { rawValue }
}
