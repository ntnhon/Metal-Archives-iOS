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
    let instrumentString: String
    let bandName: String?
}

enum LineUpType: String, CaseIterable {
    case complete = "Complete"
    case members = "Band Members"
    case guest = "Guest/Session"
    case other = "Other Staff"
}
