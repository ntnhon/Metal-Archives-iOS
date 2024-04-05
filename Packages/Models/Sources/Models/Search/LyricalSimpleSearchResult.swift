//
//  LyricalSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 16/11/2022.
//

import Foundation

public struct LyricalSimpleSearchResult: Sendable, Hashable {
    public let band: BandLite
    public let note: String? // e.g. a.k.a. D.A.D.
    public let genre: String
    public let country: Country
    public let lyricalThemes: String

    public init(band: BandLite,
                note: String?,
                genre: String,
                country: Country,
                lyricalThemes: String)
    {
        self.band = band
        self.note = note
        self.genre = genre
        self.country = country
        self.lyricalThemes = lyricalThemes
    }
}
