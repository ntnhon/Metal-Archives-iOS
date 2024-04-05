//
//  ReleaseSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/11/2022.
//

import Foundation

public struct ReleaseSimpleSearchResult: Sendable, Hashable {
    public let band: BandLite
    public let release: ReleaseLite
    public let releaseType: ReleaseType
    public let date: String

    public init(band: BandLite,
                release: ReleaseLite,
                releaseType: ReleaseType,
                date: String)
    {
        self.band = band
        self.release = release
        self.releaseType = releaseType
        self.date = date
    }
}
