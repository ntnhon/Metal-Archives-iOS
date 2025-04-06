//
//  Stats.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Foundation

public struct Stats: Sendable {
    public let timestamp: String
    public let bandStats: BandStats
    public let reviewStats: ReviewStats
    public let labelStats: LabelStats
    public let artistStats: ArtistStats
    public let memberStats: MemberStats
    public let releaseStats: ReleaseStats

    public init(timestamp: String,
                bandStats: BandStats,
                reviewStats: ReviewStats,
                labelStats: LabelStats,
                artistStats: ArtistStats,
                memberStats: MemberStats,
                releaseStats: ReleaseStats)
    {
        self.timestamp = timestamp
        self.bandStats = bandStats
        self.reviewStats = reviewStats
        self.labelStats = labelStats
        self.artistStats = artistStats
        self.memberStats = memberStats
        self.releaseStats = releaseStats
    }
}

public struct BandStats: Sendable {
    public let total: Int
    public let active: Int
    public let onHold: Int
    public let splitUp: Int
    public let changedName: Int
    public let unknown: Int

    static var empty: Self {
        .init(total: 0, active: 0, onHold: 0, splitUp: 0, changedName: 0, unknown: 0)
    }

    public init(total: Int,
                active: Int,
                onHold: Int,
                splitUp: Int,
                changedName: Int,
                unknown: Int)
    {
        self.total = total
        self.active = active
        self.onHold = onHold
        self.splitUp = splitUp
        self.changedName = changedName
        self.unknown = unknown
    }
}

public struct ReviewStats: Sendable {
    public let total: Int
    public let uniqueAlbums: Int

    static var empty: Self { .init(total: 0, uniqueAlbums: 0) }
}

public struct LabelStats: Sendable {
    public let total: Int
    public let active: Int
    public let closed: Int
    public let changedName: Int
    public let unknown: Int

    public static var empty: Self { .init(total: 0, active: 0, closed: 0, changedName: 0, unknown: 0) }

    public init(total: Int,
                active: Int,
                closed: Int,
                changedName: Int,
                unknown: Int)
    {
        self.total = total
        self.active = active
        self.closed = closed
        self.changedName = changedName
        self.unknown = unknown
    }
}

public struct ArtistStats: Sendable {
    public let total: Int
    public let stillPlaying: Int
    public let quitPlaying: Int
    public let deceased: Int
    public let female: Int
    public let male: Int
    public let nonBinary: Int
    public let nonGendered: Int
    public let unknown: Int

    public static var empty: Self {
        .init(total: 0,
              stillPlaying: 0,
              quitPlaying: 0,
              deceased: 0,
              female: 0,
              male: 0,
              nonBinary: 0,
              nonGendered: 0,
              unknown: 0)
    }

    public init(total: Int,
                stillPlaying: Int,
                quitPlaying: Int,
                deceased: Int,
                female: Int,
                male: Int,
                nonBinary: Int,
                nonGendered: Int,
                unknown: Int)
    {
        self.total = total
        self.stillPlaying = stillPlaying
        self.quitPlaying = quitPlaying
        self.deceased = deceased
        self.female = female
        self.male = male
        self.nonBinary = nonBinary
        self.nonGendered = nonGendered
        self.unknown = unknown
    }
}

public struct MemberStats: Sendable {
    public let total: Int
    public let active: Int
    public let inactive: Int

    public static var empty: Self { .init(total: 0, active: 0, inactive: 0) }

    public init(total: Int, active: Int, inactive: Int) {
        self.total = total
        self.active = active
        self.inactive = inactive
    }
}

public struct ReleaseStats: Sendable {
    public let albums: Int
    public let songs: Int

    public static var empty: Self { .init(albums: 0, songs: 0) }

    public init(albums: Int, songs: Int) {
        self.albums = albums
        self.songs = songs
    }
}
