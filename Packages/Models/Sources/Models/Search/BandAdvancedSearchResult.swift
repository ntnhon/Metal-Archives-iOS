//
//  BandAdvancedSearchResult.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 03/12/2022.
//

import Foundation

public enum CountryOrLocation: Sendable, Hashable {
    case country(Country)
    case location(String)
}

public struct BandAdvancedSearchResult: Sendable, Hashable {
    public let band: BandLite
    public let note: String? // e.g. a.k.a. D.A.D.
    public let genre: String
    public let countryOrLocation: CountryOrLocation
    public let year: String
    public let label: String?

    public init(band: BandLite,
                note: String?,
                genre: String,
                countryOrLocation: CountryOrLocation,
                year: String,
                label: String?)
    {
        self.band = band
        self.note = note
        self.genre = genre
        self.countryOrLocation = countryOrLocation
        self.year = year
        self.label = label
    }
}
