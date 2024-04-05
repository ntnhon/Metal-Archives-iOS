//
//  ReleaseElement.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/05/2021.
//

import Foundation

public enum ReleaseElement: Sendable {
    case song(Song)
    case side(String)
    case disc(String)
    case length(String)
}

public struct Song: Sendable {
    public let number: String
    public let title: String
    public let length: String
    public let lyricId: String?
    public let isInstrumental: Bool

    public init(number: String,
                title: String,
                length: String,
                lyricId: String?,
                isInstrumental: Bool)
    {
        self.number = number
        self.title = title
        self.length = length
        self.lyricId = lyricId
        self.isInstrumental = isInstrumental
    }
}
