//
//  LabelRelease.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 06/11/2022.
//

import Foundation

public struct LabelRelease: Sendable, Hashable {
    public let band: BandLite
    public let release: ReleaseLite
    public let type: ReleaseType
    public let year: String
    public let catalog: String
    public let format: String
    public let description: String?

    public init(band: BandLite,
                release: ReleaseLite,
                type: ReleaseType,
                year: String,
                catalog: String,
                format: String,
                description: String?)
    {
        self.band = band
        self.release = release
        self.type = type
        self.year = year
        self.catalog = catalog
        self.format = format
        self.description = description
    }
}
