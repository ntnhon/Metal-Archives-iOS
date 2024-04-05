//
//  UserSubmittedBand.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/11/2022.
//

import Foundation

public struct UserSubmittedBand: Sendable, Hashable {
    public let band: BandLite
    public let genre: String
    public let country: Country
    public let date: String

    public init(band: BandLite,
                genre: String,
                country: Country,
                date: String)
    {
        self.band = band
        self.genre = genre
        self.country = country
        self.date = date
    }
}
