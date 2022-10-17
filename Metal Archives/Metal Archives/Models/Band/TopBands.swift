//
//  TopBands.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/10/2022.
//

import Foundation
import Kanna

struct TopBands {
    let byReleases: [BandLite]
    let byReviews: [BandLite]
    let byFullLength: [BandLite]
}

extension TopBands: HTMLParsable {
    init(data: Data) throws {
        let html = try Kanna.HTML(html: data, encoding: .utf8)
        var byReleases = [BandLite]()
        var byReviews = [BandLite]()
        var byFullLength = [BandLite]()

        let parseBands: (XMLElement?) -> [BandLite] = { element in
            var bands = [BandLite]()
            guard let element else { return bands }
            for tr in element.css("tr") {
                let aTag = tr.at_css("a")
                if let bandName = aTag?.text,
                   let bandUrlString = aTag?["href"],
                   let band = BandLite(urlString: bandUrlString, name: bandName) {
                    bands.append(band)
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
