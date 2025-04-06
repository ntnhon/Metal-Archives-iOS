//
//  ThumbnailInfo.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

import Foundation

public struct ThumbnailInfo: Sendable, Hashable {
    public let id: Int
    public let urlString: String
    public let type: ThumbnailType

    public init?(urlString: String, type: ThumbnailType) {
        guard URL(string: urlString) != nil,
              let idString = urlString.components(separatedBy: "/").last,
              let id = Int(idString)
        else {
            return nil
        }
        self.id = id
        self.urlString = urlString
        self.type = type
    }
}

public protocol Thumbnailable {
    var thumbnailInfo: ThumbnailInfo { get }
}

public protocol OptionalThumbnailable {
    var thumbnailInfo: ThumbnailInfo? { get }
}

public enum ThumbnailType: Sendable, CaseIterable {
    case bandLogo, bandPhoto, artist, release, label

    public var suffix: String {
        switch self {
        case .bandLogo:
            "_logo"
        case .bandPhoto:
            "_photo"
        case .artist:
            "_artist"
        case .release:
            ""
        case .label:
            "_label"
        }
    }

    public var placeholderSystemImageName: String {
        switch self {
        case .bandLogo:
            "photo.fill"
        case .bandPhoto:
            "person.3.fill"
        case .artist:
            "person.fill"
        case .release:
            "opticaldisc"
        case .label:
            "tag.fill"
        }
    }
}
