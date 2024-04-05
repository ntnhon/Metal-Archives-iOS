//
//  BandSimilar.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

public struct BandSimilar: Sendable, Thumbnailable {
    public let thumbnailInfo: ThumbnailInfo
    public let name: String
    public let country: Country
    public let genre: String
    public let score: Int

    public init(thumbnailInfo: ThumbnailInfo,
                name: String,
                country: Country,
                genre: String,
                score: Int)
    {
        self.thumbnailInfo = thumbnailInfo
        self.name = name
        self.country = country
        self.genre = genre
        self.score = score
    }
}
