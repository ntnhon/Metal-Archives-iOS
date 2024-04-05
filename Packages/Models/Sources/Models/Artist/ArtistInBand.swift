//
//  ArtistInBand.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

public struct ArtistInBand: Sendable, Thumbnailable {
    public let thumbnailInfo: ThumbnailInfo
    public let name: String
    public let instruments: String
    public let bands: [BandLite]
    public let seeAlso: String?

    public init(thumbnailInfo: ThumbnailInfo,
                name: String,
                instruments: String,
                bands: [BandLite],
                seeAlso: String?)
    {
        self.thumbnailInfo = thumbnailInfo
        self.name = name
        self.instruments = instruments
        self.bands = bands
        self.seeAlso = seeAlso
    }
}
