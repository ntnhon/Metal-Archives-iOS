//
//  Band.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

public struct Band: Sendable {
    public let id: String
    public let urlString: String
    public let name: String
    public let country: Country
    public let genre: String
    public let status: BandStatus
    public let location: String
    public let yearOfCreation: String
    public let yearsActive: String
    public let oldBands: [BandLite]
    public let lyricalTheme: String
    public let lastLabel: LabelLite
    public let logoUrlString: String?
    public let photoUrlString: String?
    public let modificationInfo: ModificationInfo
    public var isBookmarked: Bool
    public let isLastKnownLineUp: Bool
    public let currentLineUp: [ArtistInBand] // or last known
    public let pastMembers: [ArtistInBand]
    public let liveMusicians: [ArtistInBand]

    public var hasPhoto: Bool { photoUrlString != nil }
    public var hasLogo: Bool { logoUrlString != nil }
    public var noMembers: Bool {
        currentLineUp.isEmpty && pastMembers.isEmpty && liveMusicians.isEmpty
    }

    public init(id: String,
                urlString: String,
                name: String,
                country: Country,
                genre: String,
                status: BandStatus,
                location: String,
                yearOfCreation: String,
                yearsActive: String,
                oldBands: [BandLite],
                lyricalTheme: String,
                lastLabel: LabelLite,
                logoUrlString: String?,
                photoUrlString: String?,
                modificationInfo: ModificationInfo,
                isBookmarked: Bool,
                isLastKnownLineUp: Bool,
                currentLineUp: [ArtistInBand],
                pastMembers: [ArtistInBand],
                liveMusicians: [ArtistInBand])
    {
        self.id = id
        self.urlString = urlString
        self.name = name
        self.country = country
        self.genre = genre
        self.status = status
        self.location = location
        self.yearOfCreation = yearOfCreation
        self.yearsActive = yearsActive
        self.oldBands = oldBands
        self.lyricalTheme = lyricalTheme
        self.lastLabel = lastLabel
        self.logoUrlString = logoUrlString
        self.photoUrlString = photoUrlString
        self.modificationInfo = modificationInfo
        self.isBookmarked = isBookmarked
        self.isLastKnownLineUp = isLastKnownLineUp
        self.currentLineUp = currentLineUp
        self.pastMembers = pastMembers
        self.liveMusicians = liveMusicians
    }
}
