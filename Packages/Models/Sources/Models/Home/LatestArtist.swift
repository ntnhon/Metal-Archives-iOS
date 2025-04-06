//
//  LatestArtist.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/12/2022.
//

import Foundation

public struct LatestArtist: Sendable, Hashable {
    public let date: String
    public let artist: ArtistLite
    public let realName: String?
    public let country: Country
    public let bands: [BandLite]
    public let dateAndTime: String
    public let author: UserLite

    public init(date: String,
                artist: ArtistLite,
                realName: String?,
                country: Country,
                bands: [BandLite],
                dateAndTime: String,
                author: UserLite)
    {
        self.date = date
        self.artist = artist
        self.realName = realName
        self.country = country
        self.bands = bands
        self.dateAndTime = dateAndTime
        self.author = author
    }
}

extension LatestArtist: Identifiable {
    public var id: Int { hashValue }
}
