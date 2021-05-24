//
//  ModelExtensions.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

@testable import Metal_Archives

extension ThumbnailInfo: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.urlString == rhs.urlString && lhs.type == rhs.type
    }
}

extension BandLite: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.thumbnailInfo == rhs.thumbnailInfo
    }
}

extension LabelLite: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.thumbnailInfo == rhs.thumbnailInfo
    }
}

extension ModificationInfo: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.addedOnDate == rhs.addedOnDate &&
        lhs.modifiedOnDate == rhs.modifiedOnDate &&
        lhs.addedByUser == rhs.addedByUser &&
        lhs.modifiedByUser == rhs.modifiedByUser
    }
}

extension ArtistLite: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name &&
        lhs.thumbnailInfo == rhs.thumbnailInfo &&
        lhs.instruments == rhs.instruments &&
        Set(lhs.instruments) == Set(rhs.instruments) &&
        lhs.seeAlso == rhs.seeAlso
    }
}
