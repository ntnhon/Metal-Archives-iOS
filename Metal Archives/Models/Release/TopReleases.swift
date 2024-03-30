//
//  TopReleases.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import Foundation
import Kanna

struct TopRelease {
    let release: ReleaseLite
    let band: BandLite
    let count: Int
}

struct TopReleases {
    let byReviews: [TopRelease]
    let mostOwned: [TopRelease]
    let mostWanted: [TopRelease]
}

extension TopReleases: HTMLParsable {
    init(data: Data) throws {
        let html = try Kanna.HTML(html: data, encoding: .utf8)

        var byReviews = [TopRelease]()
        var mostOwned = [TopRelease]()
        var mostWanted = [TopRelease]()

        let parseTopReleases: (XMLElement?) -> [TopRelease] = { element in
            var releases = [TopRelease]()
            guard let element else { return releases }
            for tr in element.css("tr") {
                var band: BandLite?
                var release: ReleaseLite?
                var count: Int?

                for td in tr.css("td") {
                    if let aTag = td.at_css("a"),
                       let text = aTag.text,
                       let urlString = aTag["href"]
                    {
                        if urlString.contains("bands/") {
                            band = .init(urlString: urlString, name: text)
                        } else {
                            release = .init(urlString: urlString, title: text)
                        }
                    } else if let text = td.text, !text.contains(".") {
                        count = Int(text)
                    }
                }

                if let band, let release, let count {
                    releases.append(.init(release: release, band: band, count: count))
                }
            }
            return releases
        }

        for div in html.css("div") {
            switch div["id"] {
            case "albums_reviews":
                byReviews = parseTopReleases(div)
            case "albums_owned":
                mostOwned = parseTopReleases(div)
            case "albums_wanted":
                mostWanted = parseTopReleases(div)
            default:
                break
            }
        }

        self.byReviews = byReviews
        self.mostOwned = mostOwned
        self.mostWanted = mostWanted
    }
}
