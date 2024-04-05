//
//  LabelCurrentBand.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 05/11/2022.
//

import Foundation

public struct LabelCurrentBand: Sendable, Hashable {
    public let band: BandLite
    public let genre: String
    public let country: Country

    public init(band: BandLite, genre: String, country: Country) {
        self.band = band
        self.genre = genre
        self.country = country
    }
}
