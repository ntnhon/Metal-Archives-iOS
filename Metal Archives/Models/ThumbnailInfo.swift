//
//  ThumbnailInfo.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

import Foundation

struct ThumbnailInfo {
    let id: Int
    let urlString: String
    let type: ThumbnailType

    init?(urlString: String, type: ThumbnailType) {
        guard URL(string: urlString) != nil,
              let id = urlString.components(separatedBy: "/").last?.toInt()
        else {
            return nil
        }
        self.id = id
        self.urlString = urlString
        self.type = type
    }
}

extension ThumbnailInfo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
    }
}

extension ThumbnailInfo {
    static var death: ThumbnailInfo {
        // swiftlint:disable:next force_unwrapping
        .init(urlString: "https://www.metal-archives.com/bands/Death/141", type: .bandLogo)!
    }
}

protocol Thumbnailable {
    var thumbnailInfo: ThumbnailInfo { get }
}

protocol OptionalThumbnailable {
    var thumbnailInfo: ThumbnailInfo? { get }
}

enum ThumbnailType: CaseIterable {
    case bandLogo, bandPhoto, artist, release, label

    var suffix: String {
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

    var placeholderSystemImageName: String {
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
