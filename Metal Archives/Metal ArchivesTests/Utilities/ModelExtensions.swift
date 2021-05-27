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

extension ThumbnailInfo: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.urlString == rhs.urlString && lhs.type == rhs.type
    }
}

extension ReleaseElement: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.song(lNumber, lTitle, lLength, lLyricId, lIsInstrumental),
                  .song(rNumber, rTitle, rLength, rLyricId, rIsInstrumental)):
            return lNumber == rNumber &&
                lTitle == rTitle &&
                lLength == rLength &&
                lLyricId == rLyricId &&
                lIsInstrumental == rIsInstrumental

        case let (.side(lValue), side(rValue)): return lValue == rValue
        case let (.disc(lValue), disc(rValue)): return lValue == rValue
        case let (.length(lValue), length(rValue)): return lValue == rValue
        default: return false
        }
    }
}
