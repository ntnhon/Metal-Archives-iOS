//
//  ReviewLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 25/05/2021.
//

struct ReviewLite {
    let urlString: String
    let title: String
    let rating: Int
    let author: UserLite
    let date: String
}

extension ReviewLite {
    final class Builder {
        var urlString: String?
        var title: String?
        var rating: Int?
        var author: UserLite?
        var date: String?

        func build() -> ReviewLite? {
            guard let urlString = urlString else {
                Logger.log("[Building ReviewLite] urlString can not be nil.")
                return nil
            }

            guard let title = title else {
                Logger.log("[Building ReviewLite] title can not be nil.")
                return nil
            }

            guard let rating = rating else {
                Logger.log("[Building ReviewLite] rating can not be nil.")
                return nil
            }

            guard let author = author else {
                Logger.log("[Building ReviewLite] author can not be nil.")
                return nil
            }

            guard let date = date else {
                Logger.log("[Building ReviewLite] date can not be nil.")
                return nil
            }

            return ReviewLite(urlString: urlString,
                              title: title,
                              rating: rating,
                              author: author,
                              date: date)
        }
    }
}
