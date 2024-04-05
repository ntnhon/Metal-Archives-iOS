//
//  ArtistLite.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 23/10/2022.
//

import Foundation

public struct ArtistLite: Sendable, Hashable {
    public let thumbnailInfo: ThumbnailInfo
    public let name: String

    public init?(urlString: String, name: String) {
        guard let thumbnailInfo = ThumbnailInfo(urlString: urlString, type: .artist) else {
            return nil
        }
        self.thumbnailInfo = thumbnailInfo
        self.name = name
    }
}
