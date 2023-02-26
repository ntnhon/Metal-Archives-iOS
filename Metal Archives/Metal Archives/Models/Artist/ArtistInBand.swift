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
    static var chuck: ArtistInBand {
        .init(thumbnailInfo: .death,
              name: "Chuck Schuldiner",
              instruments: "Guitars, Vocals (1984-2001)",
              bands: [.controlDenied, .mantas, .slaughter, .voodoocult],
              seeAlso: "(R.I.P. 2001) See also: ex-Control Denied, ex-Mantas, ex-Slaughter, ex-Voodoocult")
    }
}

extension ArtistInBand {
    final class Builder {
        var thumbnailInfo: ThumbnailInfo?
        var name: String?
        var instruments: String?
        var bands: [BandLite]?
        var seeAlso: String?

        func build() -> ArtistInBand? {
            guard let thumbnailInfo else {
                Logger.log("[Building ArtistInBand] thumbnailInfo can not be nil.")
                return nil
            }

            guard thumbnailInfo.type == .artist else {
                Logger.log("[Building ArtistInBand] thumbnailInfo's type must be artist.")
                return nil
            }

            guard let name else {
                Logger.log("[Building ArtistInBand] name can not be nil.")
                return nil
            }

            guard let instruments else {
                Logger.log("[Building ArtistInBand] instruments can not be nil.")
                return nil
            }

            guard let bands else {
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
