//
//  UserRelease.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 09/11/2022.
//

import Foundation

public enum UserReleaseType: Int, Sendable {
    case collection = 1
    case forTrade = 2
    case wanted = 3
}

public struct UserRelease: Sendable, Hashable {
    public let bands: [BandLite]
    public let release: ReleaseLite
    public let releaseNote: String? // E.g: (Demo), (EP)...
    public let version: String
    public let note: String?

    public init(bands: [BandLite],
                release: ReleaseLite,
                releaseNote: String?,
                version: String,
                note: String?)
    {
        self.bands = bands
        self.release = release
        self.releaseNote = releaseNote
        self.version = version
        self.note = note
    }
}
