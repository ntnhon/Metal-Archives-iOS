//
//  TopReleases.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import Foundation

public struct TopRelease: Sendable {
    public let release: ReleaseLite
    public let band: BandLite
    public let count: Int

    public init(release: ReleaseLite, band: BandLite, count: Int) {
        self.release = release
        self.band = band
        self.count = count
    }
}

public struct TopReleases: Sendable {
    public let byReviews: [TopRelease]
    public let mostOwned: [TopRelease]
    public let mostWanted: [TopRelease]

    public init(byReviews: [TopRelease],
                mostOwned: [TopRelease],
                mostWanted: [TopRelease])
    {
        self.byReviews = byReviews
        self.mostOwned = mostOwned
        self.mostWanted = mostWanted
    }
}
