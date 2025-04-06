//
//  ArtistSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/11/2022.
//

import Foundation

public struct ArtistSimpleSearchResult: Sendable, Hashable {
    public let artist: ArtistLite
    public let note: String?
    public let realName: String
    public let country: Country
    public let bands: [BandLite]
    public let bandsString: String

    public init(artist: ArtistLite,
                note: String?,
                realName: String,
                country: Country,
                bands: [BandLite],
                bandsString: String)
    {
        self.artist = artist
        self.note = note
        self.realName = realName
        self.country = country
        self.bands = bands
        self.bandsString = bandsString
    }
}
