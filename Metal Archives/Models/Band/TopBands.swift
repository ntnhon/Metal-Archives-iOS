//
//  TopBands.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import Foundation
import Kanna

struct TopBands {
    let byReleases: [TopBand]
    let byReviews: [TopBand]
    let byFullLength: [TopBand]
}

struct TopBand {
    let band: BandLite
    let count: Int
}

extension TopBands: HTMLParsable {
    init(data: Data) throws {
        let html = try Kanna.HTML(html: data, encoding: .utf8)
        var byReleases = [TopBand]()
        var byReviews = [TopBand]()
        var byFullLength = [TopBand]()

        let parseBands: (XMLElement?) -> [TopBand] = { element in
            guard let element else { return [] }
            var bands = [TopBand]()
            for tr in element.css("tr") {
                var bandName: String?
                var bandUrlString: String?
                var count: Int?

                for td in tr.css("td") {
                    if let aTag = td.at_css("a") {
                        bandName = aTag.text
                        bandUrlString = aTag["href"]
                    } else if let text = td.text, !text.contains("") {
                        count = Int(text)
                    }
                }

                if let bandName, let bandUrlString, let count,
                   let band = BandLite(urlString: bandUrlString, name: bandName) {
                    bands.append(.init(band: band, count: count))
                }
            }
            return bands
        }

        for div in html.css("div") {
            switch div["id"] {
            case "bands_releases":
                byReleases = parseBands(div)
            case "bands_reviews":
                byReviews = parseBands(div)
            case "bands_full_lengths":
                byFullLength = parseBands(div)
            default:
                break
            }
        }

        self.byReleases = byReleases
        self.byReviews = byReviews
        self.byFullLength = byFullLength
    }
}
