//
//  TopUsers.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 18/10/2022.
//

import Foundation

public struct TopUsers: Sendable {
    public let bySubmittedBands: [TopUser]
    public let byWrittenReviews: [TopUser]
    public let bySubmittedAlbums: [TopUser]
    public let byArtistsAdded: [TopUser]

    public init(bySubmittedBands: [TopUser],
                byWrittenReviews: [TopUser],
                bySubmittedAlbums: [TopUser],
                byArtistsAdded: [TopUser])
    {
        self.bySubmittedBands = bySubmittedBands
        self.byWrittenReviews = byWrittenReviews
        self.bySubmittedAlbums = bySubmittedAlbums
        self.byArtistsAdded = byArtistsAdded
    }
}

public struct TopUser: Sendable {
    public let user: UserLite
    public let count: Int

    public init(user: UserLite, count: Int) {
        self.user = user
        self.count = count
    }
}
