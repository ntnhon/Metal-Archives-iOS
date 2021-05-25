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
              let id = urlString.components(separatedBy: "/").last?.toInt() else {
            return nil
        }
        self.id = id
        self.urlString = urlString
        self.type = type
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

    var additionalString: String {
        switch self {
        case .bandLogo: return "_logo"
        case .bandPhoto: return "_photo"
        case .artist: return "_artist"
        case .release: return ""
        case .label: return "_label"
        }
    }
}
