//
//  Artist.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2021.
//

import Foundation

public struct Artist: Sendable {
    public let artistName: String
    public let realFullName: String
    public let age: String
    public let origin: String
    public let gender: String
    public let rip: String?
    public let causeOfDeath: String?
    public let photoUrlString: String?
    public let biography: String?
    public let hasMoreBiography: Bool
    public let trivia: String?
    public var isBookmarked: Bool
    public let modificationInfo: ModificationInfo
    public let activeRoles: [RoleInBand]
    public let pastRoles: [RoleInBand]
    public let liveRoles: [RoleInBand]
    public let guestSessionRoles: [RoleInBand]
    public let miscStaffRoles: [RoleInBand]

    public var hasPhoto: Bool { photoUrlString != nil }

    public init(artistName: String,
                realFullName: String,
                age: String,
                origin: String,
                gender: String,
                rip: String?,
                causeOfDeath: String?,
                photoUrlString: String?,
                biography: String?,
                hasMoreBiography: Bool,
                trivia: String?,
                isBookmarked: Bool,
                modificationInfo: ModificationInfo,
                activeRoles: [RoleInBand],
                pastRoles: [RoleInBand],
                liveRoles: [RoleInBand],
                guestSessionRoles: [RoleInBand],
                miscStaffRoles: [RoleInBand])
    {
        self.artistName = artistName
        self.realFullName = realFullName
        self.age = age
        self.origin = origin
        self.gender = gender
        self.rip = rip
        self.causeOfDeath = causeOfDeath
        self.photoUrlString = photoUrlString
        self.biography = biography
        self.hasMoreBiography = hasMoreBiography
        self.trivia = trivia
        self.isBookmarked = isBookmarked
        self.modificationInfo = modificationInfo
        self.activeRoles = activeRoles
        self.pastRoles = pastRoles
        self.liveRoles = liveRoles
        self.guestSessionRoles = guestSessionRoles
        self.miscStaffRoles = miscStaffRoles
    }
}
