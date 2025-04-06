//
//  Discography.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

public struct Discography: Sendable {
    public let releases: [ReleaseInBand]
    public let reviewCount: Int

    public init(releases: [ReleaseInBand], reviewCount: Int) {
        self.releases = releases
        self.reviewCount = reviewCount
    }
}
