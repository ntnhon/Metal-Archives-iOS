//
//  ArtistInBand.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

struct ArtistInBand: Thumbnailable {
    let thumbnailInfo: ThumbnailInfo
    let name: String
    let instruments: String
    let bands: [BandLite]
    let seeAlso: String?
}

extension ArtistInBand {
    final class Builder {
        var thumbnailInfo: ThumbnailInfo?
        var name: String?
        var instruments: String?
        var bands: [BandLite]?
        var seeAlso: String?

        func build() -> ArtistInBand? {
            guard let thumbnailInfo = thumbnailInfo else {
                Logger.log("[Building ArtistInBand] thumbnailInfo can not be nil.")
                return nil
            }

            guard thumbnailInfo.type == .artist else {
                Logger.log("[Building ArtistInBand] thumbnailInfo's type must be artist.")
                return nil
            }

            guard let name = name else {
                Logger.log("[Building ArtistInBand] name can not be nil.")
                return nil
            }

            guard let instruments = instruments else {
                Logger.log("[Building ArtistInBand] instruments can not be nil.")
                return nil
            }

            guard let bands = bands else {
                Logger.log("[Building ArtistInBand] bands can not be nil.")
                return nil
            }

            return ArtistInBand(thumbnailInfo: thumbnailInfo,
                                name: name,
                                instruments: instruments,
                                bands: bands,
                                seeAlso: seeAlso)
        }
    }
}
