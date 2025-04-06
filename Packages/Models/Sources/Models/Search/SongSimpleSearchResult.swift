//
//  SongSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/11/2022.
//

import Foundation

public struct SongSimpleSearchResult: Sendable, Hashable {
    public let band: BandExtraLite
    public let release: ReleaseLite
    public let releaseType: ReleaseType
    public let title: String

    public init(band: BandExtraLite,
                release: ReleaseLite,
                releaseType: ReleaseType,
                title: String)
    {
        self.band = band
        self.release = release
        self.releaseType = releaseType
        self.title = title
    }
}
