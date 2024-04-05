//
//  BandLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation

public struct BandLite: Sendable, Hashable, Thumbnailable {
    public let thumbnailInfo: ThumbnailInfo
    public let name: String

    init?(urlString: String, name: String) {
        guard let thumbnailInfo = ThumbnailInfo(urlString: urlString, type: .bandLogo) else {
            return nil
        }
        self.thumbnailInfo = thumbnailInfo
        self.name = name
    }
}

extension BandLite: Identifiable {
    public var id: Int { hashValue }
}

public struct BandExtraLite: Sendable, Hashable, OptionalThumbnailable {
    public let thumbnailInfo: ThumbnailInfo?
    public let name: String

    public init(urlString: String?, name: String) {
        if let urlString {
            thumbnailInfo = ThumbnailInfo(urlString: urlString, type: .bandLogo)
        } else {
            thumbnailInfo = nil
        }
        self.name = name
    }

    public func toBandLite() -> BandLite? {
        guard let urlString = thumbnailInfo?.urlString else { return nil }
        return .init(urlString: urlString, name: name)
    }
}
