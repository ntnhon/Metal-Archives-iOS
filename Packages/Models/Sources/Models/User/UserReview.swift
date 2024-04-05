//
//  UserReview.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 07/11/2022.
//

import Foundation

public struct UserReview: Sendable, Hashable {
    public let urlString: String
    public let date: String
    public let band: BandLite
    public let release: ReleaseLite
    public let title: String
    public let rating: Int

    public init(urlString: String,
                date: String,
                band: BandLite,
                release: ReleaseLite,
                title: String,
                rating: Int)
    {
        self.urlString = urlString
        self.date = date
        self.band = band
        self.release = release
        self.title = title
        self.rating = rating
    }
}
