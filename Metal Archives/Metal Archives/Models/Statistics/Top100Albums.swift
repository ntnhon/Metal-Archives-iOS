//
//  Top100Albums.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

final class Top100Albums {
    let byReviews: [AlbumTop]
    let mostOwned: [AlbumTop]
    let mostWanted: [AlbumTop]
    
    init(byReviews: [AlbumTop], mostOwned: [AlbumTop], mostWanted: [AlbumTop]) {
        self.byReviews = byReviews
        self.mostOwned = mostOwned
        self.mostWanted = mostWanted
    }
    
    convenience init?(fromData data: Data) {
        var byReviews: [AlbumTop]?
        var mostOwned: [AlbumTop]?
        var mostWanted: [AlbumTop]?
        
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8),
            let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) else {
                return nil
        }
        
        
        for div in doc.css("div") {
            if div["id"] == "albums_reviews" {
                if let table = div.at_css("table") {
                    byReviews = Top100Albums.parseAlbumTop(fromTable: table)
                }
            } else if div["id"] == "albums_owned" {
                if let table = div.at_css("table") {
                    mostOwned = Top100Albums.parseAlbumTop(fromTable: table)
                }
            } else if div["id"] == "albums_wanted" {
                if let table = div.at_css("table") {
                    mostWanted = Top100Albums.parseAlbumTop(fromTable: table)
                }
            }
        }
        
        if let byReviews = byReviews, let mostOwned = mostOwned, let mostWanted = mostWanted {
            self.init(byReviews: byReviews, mostOwned: mostOwned, mostWanted: mostWanted)
        } else {
            return nil
        }
    }
    
    private static func parseAlbumTop(fromTable table: XMLElement) -> [AlbumTop]? {
        var albumTops: [AlbumTop] = []
        
        let trs = table.css("tr")
        trs.forEach { (tr) in
            var band: BandLite?
            var release: ReleaseExtraLite?
            var count: Int?
            
            let tds = tr.css("td")
            for i in 0..<tds.count {
                if i == 1 {
                    if let a = tds[i].at_css("a"), let bandName = a.text, let bandURLString = a["href"] {
                        band = BandLite(name: bandName, urlString: bandURLString)
                    }
                } else if i == 2 {
                    if let a = tds[i].at_css("a"), let releaseTitle = a.text, let releaseURLString = a["href"] {
                        release = ReleaseExtraLite(urlString: releaseURLString, title: releaseTitle)
                    }
                } else if i == 3 {
                    if let countString = tds[i].text {
                        count = Int(countString)
                    }
                }
            }
            
            if let `band` = band, let `release` = release, let `count` = count {
                if let album = AlbumTop(band: band, release: release, count: count) {
                    albumTops.append(album)
                }
            }
        }
        
        if albumTops.count > 0 {
            return albumTops
        } else {
            return nil
        }
    }
}
