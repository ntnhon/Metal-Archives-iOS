//
//  TopBands.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import Foundation

public struct TopBands: Sendable {
    public let byReleases: [TopBand]
    public let byReviews: [TopBand]
    public let byFullLength: [TopBand]

    public init(byReleases: [TopBand],
                byReviews: [TopBand],
                byFullLength: [TopBand])
    {
        self.byReleases = byReleases
        self.byReviews = byReviews
        self.byFullLength = byFullLength
    }
}

public struct TopBand: Sendable {
    public let band: BandLite
    public let count: Int

    public init(band: BandLite, count: Int) {
        self.band = band
        self.count = count
    }
}
