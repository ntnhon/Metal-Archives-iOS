//
//  BandByAlphabet.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 20/10/2022.
//

import Foundation

public typealias BandByGenre = BandByAlphabet

public struct BandByAlphabet: Sendable, Hashable {
    public let band: BandLite
    public let country: Country
    public let genre: String
    public let status: BandStatus

    public init(band: BandLite,
                country: Country,
                genre: String,
                status: BandStatus)
    {
        self.band = band
        self.country = country
        self.genre = genre
        self.status = status
    }
}
