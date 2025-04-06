//
//  LatestReview.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/12/2022.
//

import Foundation

public struct LatestReview: Sendable, Hashable {
    public let urlString: String
    public let bands: [BandLite]
    public let release: ReleaseLite
    public let rating: Int
    public let author: UserLite
    public let date: String
    public let time: String

    public var bandsName: String {
        bands.map { $0.name }.joined(separator: " & ")
    }

    public init(urlString: String,
                bands: [BandLite],
                release: ReleaseLite,
                rating: Int,
                author: UserLite,
                date: String,
                time: String)
    {
        self.urlString = urlString
        self.bands = bands
        self.release = release
        self.rating = rating
        self.author = author
        self.date = date
        self.time = time
    }
}

extension LatestReview: Identifiable {
    public var id: Int { hashValue }
}
