//
//  BandSimilar.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 22/05/2021.
//

import Foundation
import Kanna

struct BandSimilar {
    let urlString: String
    let name: String
    let country: Country
    let genre: String
    let score: Int
}

extension BandSimilar {
    final class Builder {
        var urlString: String?
        var name: String?
        var country: Country?
        var genre: String?
        var score: Int?

        func build() -> BandSimilar? {
            guard let urlString = urlString else {
                print("[Building BandSimilar] urlString can not be nil.")
                return nil
            }

            guard let name = name else {
                print("[Building BandSimilar] name can not be nil.")
                return nil
            }

            guard let country = country else {
                print("[Building BandSimilar] country can not be nil.")
                return nil
            }

            guard let genre = genre else {
                print("[Building BandSimilar] genre can not be nil.")
                return nil
            }

            guard let score = score else {
                print("[Building BandSimilar] score can not be nil.")
                return nil
            }

            return BandSimilar(urlString: urlString,
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
                    let a = td.at_css("a")
                    builder.name = a?.text
                    builder.urlString = a?["href"]
                case countryColumn:
                    let country = CountryManager.shared.country(by: \.name, value: td.text ?? "")
                    builder.country = country
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
