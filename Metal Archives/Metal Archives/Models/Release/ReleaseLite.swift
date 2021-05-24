//
//  ReleaseLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

struct ReleaseLite: Thumbnailable {
    let thumbnailInfo: ThumbnailInfo
    let title: String
    let type: ReleaseType
    let year: Int
    let reviewCount: Int?
    let rating: Int?
    let reviewsUrlString: String?
}

extension ReleaseLite {
    final class Builder {
        var thumbnailInfo: ThumbnailInfo?
        var title: String?
        var type: ReleaseType?
        var year: Int?
        var reviewCount: Int?
        var rating: Int?
        var reviewsUrlString: String?

        func build() -> ReleaseLite? {
            guard let thumbnailInfo = thumbnailInfo else {
                Logger.log("thumbnailInfo can not be nil.")
                return nil
            }

            guard thumbnailInfo.type == .release else {
                Logger.log("thumbnailInfo's type must be release.")
                return nil
            }

            guard let title = title else {
                Logger.log("title can not be nil.")
                return nil
            }

            guard let type = type else {
                Logger.log("type can not be nil.")
                return nil
            }

            guard let year = year else {
                Logger.log("year can not be nil.")
                return nil
            }

            return ReleaseLite(thumbnailInfo: thumbnailInfo,
                               title: title,
                               type: type,
                               year: year,
                               reviewCount: reviewCount,
                               rating: rating,
                               reviewsUrlString: reviewsUrlString)
        }
    }
}
