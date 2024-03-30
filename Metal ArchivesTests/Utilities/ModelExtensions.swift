//
//  ModelExtensions.swift
//  Metal ArchivesTests
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

@testable import Metal_Archives

extension ArtistInBand: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name &&
            lhs.thumbnailInfo == rhs.thumbnailInfo &&
            lhs.instruments == rhs.instruments &&
            Set(lhs.instruments) == Set(rhs.instruments) &&
            lhs.seeAlso == rhs.seeAlso
    }
}

extension ModificationInfo: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.addedOnDate == rhs.addedOnDate &&
            lhs.modifiedOnDate == rhs.modifiedOnDate &&
            lhs.addedByUser?.urlString == rhs.addedByUser?.urlString &&
            lhs.modifiedByUser?.urlString == rhs.modifiedByUser?.urlString
    }
}

extension ReleaseElement: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.song(lhsSong), .song(rhsSong)):
            lhsSong == rhsSong
        case let (.side(lValue), side(rValue)):
            lValue == rValue
        case let (.disc(lValue), disc(rValue)):
            lValue == rValue
        case let (.length(lValue), length(rValue)):
            lValue == rValue
        default:
            false
        }
    }
}

extension Song: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.number == rhs.number &&
            lhs.title == rhs.title &&
            lhs.length == rhs.length &&
            lhs.lyricId == rhs.lyricId &&
            lhs.isInstrumental == rhs.isInstrumental
    }
}
