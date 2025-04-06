//
//  ReviewLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/05/2021.
//

import Foundation

public struct ReviewLite: Sendable {
    public let urlString: String
    public let title: String
    public let rating: Int
    public let author: UserLite
    public let date: String

    public init(urlString: String,
                title: String,
                rating: Int,
                author: UserLite,
                date: String)
    {
        self.urlString = urlString
        self.title = title
        self.rating = rating
        self.author = author
        self.date = date
    }
}
