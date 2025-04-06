//
//  Review.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 06/11/2022.
//

import Foundation

public struct Review: Sendable {
    public let band: BandLite
    public let release: ReleaseLite
    public let coverPhotoUrlString: String?
    public let title: String
    public let rating: Int
    public let user: UserLite
    public let date: String
    public let baseVersion: ReleaseLite?
    public let content: String

    public init(band: BandLite,
                release: ReleaseLite,
                coverPhotoUrlString: String?,
                title: String,
                rating: Int,
                user: UserLite,
                date: String,
                baseVersion: ReleaseLite?,
                content: String)
    {
        self.band = band
        self.release = release
        self.coverPhotoUrlString = coverPhotoUrlString
        self.title = title
        self.rating = rating
        self.user = user
        self.date = date
        self.baseVersion = baseVersion
        self.content = content
    }
}
