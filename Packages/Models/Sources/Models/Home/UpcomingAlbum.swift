//
//  UpcomingAlbum.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 04/12/2022.
//

import Foundation

public struct UpcomingAlbum: Sendable, Hashable {
    public let bands: [BandLite]
    public let release: ReleaseLite
    public let releaseType: ReleaseType
    public let genre: String
    public let date: String

    public var bandsName: String {
        bands.map { $0.name }.joined(separator: " & ")
    }

    public init(bands: [BandLite],
                release: ReleaseLite,
                releaseType: ReleaseType,
                genre: String,
                date: String)
    {
        self.bands = bands
        self.release = release
        self.releaseType = releaseType
        self.genre = genre
        self.date = date
    }
}

extension UpcomingAlbum: Identifiable {
    public var id: Int { hashValue }
}
