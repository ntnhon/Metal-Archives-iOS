//
//  BandByCountry.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/10/2022.
//

import Foundation

public struct BandByCountry: Sendable, Hashable {
    public let band: BandLite
    public let genre: String
    public let location: String
    public let status: BandStatus

    public init(band: BandLite,
                genre: String,
                location: String,
                status: BandStatus)
    {
        self.band = band
        self.genre = genre
        self.location = location
        self.status = status
    }
}
