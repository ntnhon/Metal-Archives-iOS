//
//  ArtistLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

struct ArtistLite: Thumbnailable {
    let thumbnailInfo: ThumbnailInfo
    let name: String
    let instruments: String
    let bands: [BandLite]
    let seeAlso: String?
}

extension ArtistLite {
    final class Builder {
        var thumbnailInfo: ThumbnailInfo?
        var name: String?
        var instruments: String?
        var bands: [BandLite]?
        var seeAlso: String?

        func build() -> ArtistLite? {
            guard let thumbnailInfo = thumbnailInfo else {
                Logger.log("thumbnailInfo can not be nil.")
                return nil
            }

            guard thumbnailInfo.type == .artist else {
                Logger.log("thumbnailInfo's type must be artist.")
                return nil
            }

            guard let name = name else {
                Logger.log("name can not be nil.")
                return nil
            }

            guard let instruments = instruments else {
                Logger.log("instruments can not be nil.")
                return nil
            }

            guard let bands = bands else {
                Logger.log("bands can not be nil.")
                return nil
            }

            return ArtistLite(thumbnailInfo: thumbnailInfo,
                              name: name,
                              instruments: instruments,
                              bands: bands,
                              seeAlso: seeAlso)
        }
    }
}
