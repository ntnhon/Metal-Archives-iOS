//
//  ArtistInRelease.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/05/2021.
//

struct ArtistInRelease: Thumbnailable {
    let thumbnailInfo: ThumbnailInfo
    let name: String
    let additionalDetail: String?
    let lineUpType: LineUpType
    let instruments: String
    let bandName: String?
}

enum LineUpType: String, CaseIterable {
    case members = "Band Members"
    case guest = "Guest/Session"
    case other = "Other Staff"
}

extension ArtistInRelease {
    final class Builder {
        var thumbnailInfo: ThumbnailInfo?
        var name: String?
        var additionalDetail: String?
        var lineUpType: LineUpType?
        var instruments: String?
        var bandName: String?

        func build() -> ArtistInRelease? {
            guard let thumbnailInfo else {
                Logger.log("[Building ArtistInRelease] thumbnailInfo can not be nil.")
                return nil
            }

            guard let name else {
                Logger.log("[Building ArtistInRelease] name can not be nil.")
                return nil
            }

            guard let lineUpType else {
                Logger.log("[Building ArtistInRelease] lineUpType can not be nil.")
                return nil
            }

            guard let instruments else {
                Logger.log("[Building ArtistInRelease] instruments can not be nil.")
                return nil
            }

            return ArtistInRelease(thumbnailInfo: thumbnailInfo,
                                   name: name,
                                   additionalDetail: additionalDetail,
                                   lineUpType: lineUpType,
                                   instruments: instruments,
                                   bandName: bandName)
        }
    }
}
