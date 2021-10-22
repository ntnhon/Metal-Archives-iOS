//
//  ReleaseInBand.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

struct ReleaseInBand: Thumbnailable {
    let thumbnailInfo: ThumbnailInfo
    let title: String
    let type: ReleaseType
    let year: Int
    let reviewCount: Int?
    let rating: Int?
    let reviewsUrlString: String?
    let isPlatinium: Bool

    var photoDescription: String {
        "\(title)\n\(year) • \(type.description)"
    }
}

extension ReleaseInBand {
    final class Builder {
        var thumbnailInfo: ThumbnailInfo?
        var title: String?
        var type: ReleaseType?
        var year: Int?
        var reviewCount: Int?
        var rating: Int?
        var reviewsUrlString: String?

        func build() -> ReleaseInBand? {
            guard let thumbnailInfo = thumbnailInfo else {
                Logger.log("[Building ReleaseInBand] thumbnailInfo can not be nil.")
                return nil
            }

            guard thumbnailInfo.type == .release else {
                Logger.log("[Building ReleaseInBand] thumbnailInfo's type must be release.")
                return nil
            }

            guard let title = title else {
                Logger.log("[Building ReleaseInBand] title can not be nil.")
                return nil
            }

            guard let type = type else {
                Logger.log("[Building ReleaseInBand] type can not be nil.")
                return nil
            }

            guard let year = year else {
                Logger.log("[Building ReleaseInBand] year can not be nil.")
                return nil
            }

            let isPlatinium = (reviewCount ?? 0) >= 10 && (rating ?? 0) >= 75

            return ReleaseInBand(thumbnailInfo: thumbnailInfo,
                                 title: title,
                                 type: type,
                                 year: year,
                                 reviewCount: reviewCount,
                                 rating: rating,
                                 reviewsUrlString: reviewsUrlString,
                                 isPlatinium: isPlatinium)
        }
    }
}
