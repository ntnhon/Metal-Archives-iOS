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
            guard let thumbnailInfo else {
                Logger.log("[Building BandSimilar] thumbnailInfo can not be nil.")
                return nil
            }

            guard thumbnailInfo.type == .bandLogo else {
                Logger.log("[Building BandSimilar] thumbnailInfo must be bandLogo.")
                return nil
            }

            guard let name else {
                Logger.log("[Building BandSimilar] name can not be nil.")
                return nil
            }

            guard let country else {
                Logger.log("[Building BandSimilar] country can not be nil.")
                return nil
            }

            guard let genre else {
                Logger.log("[Building BandSimilar] genre can not be nil.")
                return nil
            }

            guard let score else {
                Logger.log("[Building BandSimilar] score can not be nil.")
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

struct BandSimilarArray: HTMLParsable {
    let content: [BandSimilar]

    // Sample: https://www.metal-archives.com/band/ajax-recommendations/id/141/showMoreSimilar/1
    init(data: Data) {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
              let html = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8),
              let tbody = html.at_css("tbody") else {
            Logger.log("Error parsing html for list of similar artist")
            content = []
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
            if tr.text?.contains("(show top 20 only)") == true { continue }
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
        content = bands
    }
}
