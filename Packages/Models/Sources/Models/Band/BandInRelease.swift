//
//  BandInRelease.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/05/2021.
//

import Foundation

// In case of Split or Original line up
// members are separated by bands
public struct BandInRelease: Sendable, Hashable {
    public let name: String?
    public let members: [ArtistInRelease]

    public init(name: String?, members: [ArtistInRelease]) {
        self.name = name
        self.members = members
    }
}
