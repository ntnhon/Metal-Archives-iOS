//
//  DeceasedArtist.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Foundation

public struct DeceasedArtist: Sendable, Hashable {
    public let artist: ArtistLite
    public let country: Country
    public let bands: [BandLite]
    public let bandsString: String
    public let dateOfDeath: String
    public let causeOfDeath: String

    public init(artist: ArtistLite,
                country: Country,
                bands: [BandLite],
                bandsString: String,
                dateOfDeath: String,
                causeOfDeath: String)
    {
        self.artist = artist
        self.country = country
        self.bands = bands
        self.bandsString = bandsString
        self.dateOfDeath = dateOfDeath
        self.causeOfDeath = causeOfDeath
    }
}
