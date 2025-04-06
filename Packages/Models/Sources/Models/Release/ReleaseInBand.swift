//
//  ReleaseInBand.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

public struct ReleaseInBand: Sendable, Thumbnailable {
    public let thumbnailInfo: ThumbnailInfo
    public let title: String
    public let type: ReleaseType
    public let year: Int
    public let reviewCount: Int?
    public let rating: Int?
    public let reviewsUrlString: String?
    public let isPlatinium: Bool

    public var photoDescription: String {
        "\(title)\n\(year) • \(type.description)"
    }

    public init(thumbnailInfo: ThumbnailInfo,
                title: String,
                type: ReleaseType,
                year: Int,
                reviewCount: Int?,
                rating: Int?,
                reviewsUrlString: String?,
                isPlatinium: Bool)
    {
        self.thumbnailInfo = thumbnailInfo
        self.title = title
        self.type = type
        self.year = year
        self.reviewCount = reviewCount
        self.rating = rating
        self.reviewsUrlString = reviewsUrlString
        self.isPlatinium = isPlatinium
    }
}
