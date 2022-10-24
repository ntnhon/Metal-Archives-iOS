//
//  Stats.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Foundation
import Kanna
import RegexBuilder

struct Stats {
    let timestamp: String
    let bandStats: BandStats
    let reviewStats: ReviewStats
    let labelStats: LabelStats
    let artistStats: ArtistStats
    let memberStats: MemberStats
    let releaseStats: ReleaseStats
}

struct BandStats {
    let total: Int
    let active: Int
    let onHold: Int
    let splitUp: Int
    let changedName: Int
    let unknown: Int
}

struct ReviewStats {
    let total: Int
    let uniqueAlbums: Int
}

struct LabelStats {
    let total: Int
    let active: Int
    let closed: Int
    let changedName: Int
    let unknown: Int
}

struct ArtistStats {
    let total: Int
    let stillPlaying: Int
    let quitPlaying: Int
    let deceased: Int
    let female: Int
    let male: Int
    let nonBinary: Int
    let nonGendered: Int
    let unknown: Int
}

struct MemberStats {
    let total: Int
    let active: Int
    let inactive: Int
}

struct ReleaseStats {
    let albums: Int
    let songs: Int
}

extension Stats: HTMLParsable {
    init(data: Data) throws {
        let html = try Kanna.HTML(html: data, encoding: .utf8)
        self.timestamp = ""
        self.bandStats = .init(total: 0,
                               active: 0,
                               onHold: 0,
                               splitUp: 0,
                               changedName: 0,
                               unknown: 0)
        self.reviewStats = .init(total: 0, uniqueAlbums: 0)
        self.labelStats = .init(total: 0, active: 0, closed: 0, changedName: 0, unknown: 0)
        self.artistStats = .init(total: 0,
                                 stillPlaying: 0,
                                 quitPlaying: 0,
                                 deceased: 0,
                                 female: 0,
                                 male: 0,
                                 nonBinary: 0,
                                 nonGendered: 0,
                                 unknown: 0)
        self.memberStats = .init(total: 0, active: 0, inactive: 0)
        self.releaseStats = .init(albums: 0, songs: 0)
    }
}
