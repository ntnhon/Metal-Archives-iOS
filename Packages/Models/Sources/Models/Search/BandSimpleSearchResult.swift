//
//  BandSimpleSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 15/11/2022.
//

import Foundation

public struct BandSimpleSearchResult: Sendable, Hashable {
    public let band: BandLite
    public let note: String? // e.g. a.k.a. D.A.D.
    public let genre: String
    public let country: Country

    public init(band: BandLite,
                note: String?,
                genre: String,
                country: Country)
    {
        self.band = band
        self.note = note
        self.genre = genre
        self.country = country
    }
}
