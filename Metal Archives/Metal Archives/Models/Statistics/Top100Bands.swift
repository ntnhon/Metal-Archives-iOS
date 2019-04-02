//
//  Top100Bands.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

final class Top100Bands {
    let byReleases: [BandTop]
    let byFullLengths: [BandTop]
    let byReviews: [BandTop]
    
    init(byReleases: [BandTop], byFullLengths: [BandTop], byReviews: [BandTop]) {
        self.byReleases = byReleases
        self.byFullLengths = byFullLengths
        self.byReviews = byReviews
    }
    
    convenience init?(fromData data: Data) {
        var byReleases: [BandTop]?
        var byFullLengths: [BandTop]?
        var byReviews: [BandTop]?
        
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
        }
        
        
        for div in doc.css("div") {
            if div["id"] == "bands_releases" {
                if let table = div.at_css("table") {
                    byReleases = Top100Bands.parseBandTop(fromTable: table)
                }
            } else if div["id"] == "bands_full_lengths" {
                if let table = div.at_css("table") {
                    byFullLengths = Top100Bands.parseBandTop(fromTable: table)
                }
            } else if div["id"] == "bands_reviews" {
                if let table = div.at_css("table") {
                    byReviews = Top100Bands.parseBandTop(fromTable: table)
                }
            }
        }
        
        if let `byReleases` = byReleases, let `byFullLengths` = byFullLengths, let `byReviews` = byReviews {
            self.init(byReleases: byReleases, byFullLengths: byFullLengths, byReviews: byReviews)
        } else {
            return nil
        }
    }
    
    private static func parseBandTop(fromTable table: XMLElement) -> [BandTop]? {
        var bandTops: [BandTop] = []
        
        let trs = table.css("tr")
        trs.forEach { (tr) in
            var name: String?
            var urlString: String?
            var count: Int?
            
            let tds = tr.css("td")
            for i in 0..<tds.count {
                if i == 1 {
                    if let a = tds[i].at_css("a"), let bandName = a.text, let bandURLString = a["href"] {
                        name = bandName
                        urlString = bandURLString
                    }
                } else if i == 2 {
                    if let countString = tds[i].text {
                        count = Int(countString)
                    }
                }
            }
            
            if let `name` = name, let `urlString` = urlString, let `count` = count {
                if let band = BandTop(urlString: urlString, name: name, count: count) {
                    bandTops.append(band)
                }
            }
        }
        
        if bandTops.count > 0 {
            return bandTops
        } else {
            return nil
        }
    }
}
