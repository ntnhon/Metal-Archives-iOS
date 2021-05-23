//
//  ReleaseLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

struct ReleaseLite {
    let urlString: String
    let title: String
    let type: ReleaseType
    let year: Int
    let reviewCount: Int?
    let rating: Int?
    let reviewsUrlString: String?
}

extension ReleaseLite {
    final class Builder {
        var urlString: String?
        var title: String?
        var type: ReleaseType?
        var year: Int?
        var reviewCount: Int?
        var rating: Int?
        var reviewsUrlString: String?

        func build() -> ReleaseLite? {
            guard let urlString = urlString else {
                print("[Building ReleaseLite] urlString can not be nil.")
                return nil
            }

            guard let title = title else {
                print("[Building ReleaseLite] title can not be nil.")
                return nil
            }

            guard let type = type else {
                print("[Building ReleaseLite] type can not be nil.")
                return nil
            }

            guard let year = year else {
                print("[Building ReleaseLite] year can not be nil.")
                return nil
            }

            return ReleaseLite(urlString: urlString,
                               title: title,
                               type: type,
                               year: year,
                               reviewCount: reviewCount,
                               rating: rating,
                               reviewsUrlString: reviewsUrlString)
        }
    }
}
