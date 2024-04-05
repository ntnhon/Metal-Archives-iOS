//
//  ReleaseLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 29/05/2021.
//

import Foundation

public struct ReleaseLite: Sendable, Hashable, Thumbnailable {
    public let thumbnailInfo: ThumbnailInfo
    public let title: String

    public init?(urlString: String, title: String) {
        guard let thumbnailInfo = ThumbnailInfo(urlString: urlString, type: .release) else {
            return nil
        }
        self.thumbnailInfo = thumbnailInfo
        self.title = title
    }
}
