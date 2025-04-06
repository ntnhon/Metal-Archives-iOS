//
//  ReleaseOtherVersion.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/05/2021.
//

import Foundation

public struct ReleaseOtherVersion: Sendable {
    public let urlString: String
    public let date: String
    public let labelName: String
    public let catalogId: String
    public let additionalDetail: String? // Ex: "title "Human / Symolic""
    public let isUnofficial: Bool
    public let format: String
    public let description: String
    public let isCurrentVersion: Bool

    public var thumbnailInfo: ThumbnailInfo? {
        .init(urlString: urlString, type: .release)
    }

    public init(urlString: String,
                date: String,
                labelName: String,
                catalogId: String,
                additionalDetail: String?,
                isUnofficial: Bool,
                format: String,
                description: String,
                isCurrentVersion: Bool)
    {
        self.urlString = urlString
        self.date = date
        self.labelName = labelName
        self.catalogId = catalogId
        self.additionalDetail = additionalDetail
        self.isUnofficial = isUnofficial
        self.format = format
        self.description = description
        self.isCurrentVersion = isCurrentVersion
    }
}
