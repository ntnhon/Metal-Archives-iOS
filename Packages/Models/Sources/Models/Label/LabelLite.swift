//
//  LabelLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

public struct LabelLite: Sendable, Hashable, OptionalThumbnailable {
    public let thumbnailInfo: ThumbnailInfo?
    public let name: String

    public init(thumbnailInfo: ThumbnailInfo?, name: String) {
        self.thumbnailInfo = thumbnailInfo
        self.name = name
    }
}
