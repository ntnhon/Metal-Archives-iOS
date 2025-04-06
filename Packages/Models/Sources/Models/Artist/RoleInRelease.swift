//
//  RoleInRelease.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2021.
//

import Foundation

public struct RoleInRelease: Sendable, Hashable {
    public let year: String
    public let release: ReleaseLite
    public let releaseAdditionalInfo: String?
    public let description: String

    public init(year: String,
                release: ReleaseLite,
                releaseAdditionalInfo: String?,
                description: String)
    {
        self.year = year
        self.release = release
        self.releaseAdditionalInfo = releaseAdditionalInfo
        self.description = description
    }
}
