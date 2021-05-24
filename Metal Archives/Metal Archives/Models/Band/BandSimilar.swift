//
//  BandSimilar.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation
import Kanna

struct BandSimilar: Thumbnailable {
    let thumbnailInfo: ThumbnailInfo
    let name: String
    let country: Country
    let genre: String
    let score: Int
}

extension BandSimilar {
    final class Builder {
        var thumbnailInfo: ThumbnailInfo?
        var name: String?
        var country: Country?
        var genre: String?
        var score: Int?

        func build() -> BandSimilar? {
            guard let thumbnailInfo = thumbnailInfo else {
                Logger.log("thumbnailInfo can not be nil.")
                return nil
            }

            guard thumbnailInfo.type == .bandLogo else {
                Logger.log("thumbnailInfo must be bandLogo.")
                return nil
            }

            guard let name = name else {
                Logger.log("name can not be nil.")
                return nil
            }

            guard let country = country else {
                Logger.log("country can not be nil.")
                return nil
            }

            guard let genre = genre else {
                Logger.log("genre can not be nil.")
                return nil
            }

            guard let score = score else {
                Logger.log("score can not be nil.")
                return nil
            }

            return BandSimilar(thumbnailInfo: thumbnailInfo,
                               name: name,
                               country: country,
                               genre: genre,
                               score: score)
        }
    }
}

extension Array where Element == BandSimilar {
    // Sample: https://www.metal-archives.com/band/ajax-recommendations/id/141/showMoreSimilar/1
    init(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
              let html = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8),
              let tbody = html.at_css("tbody") else {
            Logger.log("Error parsing html for list of similar artist")
            self = []
            return
        }

        // Check if user is logged in, because in this case the html structure is different
        // there is 1 more column at the beginning (for vote up/down)
        let isLoggedIn = htmlString.contains("Vote up")

        let nameColumn = isLoggedIn ? 1 : 0
        let countryColumn = isLoggedIn ? 2 : 1
        let genreColumn = isLoggedIn ? 3 : 2
        let scoreColumn = isLoggedIn ? 4 : 3

        var bands = [BandSimilar]()
        for tr in tbody.css("tr") {
            let builder = BandSimilar.Builder()
            for (column, td) in tr.css("td").enumerated() {
                if td["id"] == "no_artists" || td["id"] == "show_more" {
                    break
                }

                switch column {
                case nameColumn:
                    // swiftlint:disable:next identifier_name
                    if let a = td.at_css("a"), let bandName = a.text, let bandUrlString = a["href"] {
                        builder.name = bandName
                        builder.thumbnailInfo = ThumbnailInfo(urlString: bandUrlString, type: .bandLogo)
                    }
                case countryColumn:
                    if let countryName = td.text {
                        let country = CountryManager.shared.country(by: \.name, value: countryName)
                        builder.country = country
                    }
                case genreColumn:
                    builder.genre = td.text
                case scoreColumn:
                    let scoreString = td.at_css("span")?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    builder.score = scoreString?.toInt()
                default: break
                }
            }

            if let band = builder.build() {
                bands.append(band)
            }
        }
        self = bands
    }
}
