//
//  ArtistInRelease.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/05/2021.
//

import Foundation

public struct ArtistInRelease: Sendable, Identifiable, Hashable, Thumbnailable {
    public var id: String { thumbnailInfo.urlString }
    public let thumbnailInfo: ThumbnailInfo
    public let name: String
    public let additionalDetail: String?
    public let lineUpType: LineUpType
    public let instruments: String
    public let bandName: String?

    public init(thumbnailInfo: ThumbnailInfo,
                name: String,
                additionalDetail: String?,
                lineUpType: LineUpType,
                instruments: String,
                bandName: String?)
    {
        self.thumbnailInfo = thumbnailInfo
        self.name = name
        self.additionalDetail = additionalDetail
        self.lineUpType = lineUpType
        self.instruments = instruments
        self.bandName = bandName
    }
}

public enum LineUpType: String, Sendable, CaseIterable {
    case members = "Band Members"
    case guest = "Guest/Session"
    case other = "Other Staff"
}
