//
//  RoleInBand.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2021.
//

import Foundation

public struct RoleInBand: Sendable, Hashable {
    public let band: BandExtraLite
    public let description: String // Role and active year
    public let roleInReleases: [RoleInRelease]

    public init(band: BandExtraLite,
                description: String,
                roleInReleases: [RoleInRelease])
    {
        self.band = band
        self.description = description
        self.roleInReleases = roleInReleases
    }
}
