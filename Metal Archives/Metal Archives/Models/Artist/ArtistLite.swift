//
//  ArtistLite.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Foundation

struct ArtistLite {
    let thumbnailInfo: ThumbnailInfo
    let name: String

    init?(urlString: String, name: String) {
        guard let thumbnailInfo = ThumbnailInfo(urlString: urlString, type: .artist) else {
            return nil
        }
        self.thumbnailInfo = thumbnailInfo
        self.name = name
    }
}

extension ArtistLite: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(thumbnailInfo)
    }
}

extension ArtistLite: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.thumbnailInfo.urlString == rhs.thumbnailInfo.urlString
    }
}
