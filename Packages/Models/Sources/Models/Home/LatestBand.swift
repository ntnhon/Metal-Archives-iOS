//
//  LatestBand.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 22/12/2022.
//

import Foundation

public struct LatestBand: Sendable, Hashable {
    public let date: String
    public let band: BandLite
    public let country: Country
    public let genre: String
    public let dateAndTime: String
    public let author: UserLite

    public init(date: String,
                band: BandLite,
                country: Country,
                genre: String,
                dateAndTime: String,
                author: UserLite)
    {
        self.date = date
        self.band = band
        self.country = country
        self.genre = genre
        self.dateAndTime = dateAndTime
        self.author = author
    }
}

extension LatestBand: Identifiable {
    public var id: Int { hashValue }
}
