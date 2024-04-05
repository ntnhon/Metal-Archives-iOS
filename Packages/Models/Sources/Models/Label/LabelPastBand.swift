//
//  LabelPastBand.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 06/11/2022.
//

import Foundation

public struct LabelPastBand: Sendable, Hashable {
    public let band: BandLite
    public let genre: String
    public let country: Country
    public let releaseCount: String

    public init(band: BandLite,
                genre: String,
                country: Country,
                releaseCount: String)
    {
        self.band = band
        self.genre = genre
        self.country = country
        self.releaseCount = releaseCount
    }
}
