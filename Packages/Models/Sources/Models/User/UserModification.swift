//
//  UserModification.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 08/11/2022.
//

import Foundation

public enum UserModificationItem: Sendable, Hashable {
    case band(BandLite)
    case artist(ArtistLite)
    case release(ReleaseLite)
    case label(LabelLite)
    case unknown(String)

    public var thumbnailInfo: ThumbnailInfo? {
        switch self {
        case let .band(band):
            return band.thumbnailInfo
        case let .artist(artist):
            return artist.thumbnailInfo
        case let .release(release):
            return release.thumbnailInfo
        case let .label(label):
            return label.thumbnailInfo
        case .unknown:
            return nil
        }
    }

    public var title: String {
        switch self {
        case let .band(band):
            return band.name
        case let .artist(artist):
            return artist.name
        case let .release(release):
            return release.title
        case let .label(label):
            return label.name
        case let .unknown(text):
            return text
        }
    }

    public var systemImage: String {
        switch self {
        case .band:
            return "person.3.fill"
        case .artist:
            return "person.fill"
        case .release:
            return "opticaldisc.fill"
        case .label:
            return "tag.fill"
        case .unknown:
            return "questionmark"
        }
    }
}

public struct UserModification: Sendable, Hashable {
    #warning("Convert to relative date")
    public let date: String
    public let item: UserModificationItem
    public let note: String

    public init(date: String,
                item: UserModificationItem,
                note: String)
    {
        self.date = date
        self.item = item
        self.note = note
    }
}
