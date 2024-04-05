//
//  ReleaseAdvancedSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import Foundation

public struct ReleaseAdvancedSearchResult: Sendable, Hashable {
    public let band: BandLite
    public let release: ReleaseLite
    public let type: ReleaseType
    public let otherInfo: [String]

    public init(band: BandLite,
                release: ReleaseLite,
                type: ReleaseType,
                otherInfo: [String])
    {
        self.band = band
        self.release = release
        self.type = type
        self.otherInfo = otherInfo
    }
}
