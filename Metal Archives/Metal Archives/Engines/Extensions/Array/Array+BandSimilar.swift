//
//  Array+BandSimilar.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 06/05/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
import Kanna

extension Array where Element == BandSimilar {
    static func from(data: Data) -> [BandSimilar]? {
        guard let htmlString = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        // Check if user is logged in, because in this case the html structure is different
        // there is 1 more column at the beginning (for vote up/down)
        let isLoggedIn = htmlString.contains("Vote up")
        
        let nameColumn = isLoggedIn ? 1 : 0
        let countryColumn = isLoggedIn ? 2 : 1
        let genreColumn = isLoggedIn ? 3 : 2
        let scoreColumn = isLoggedIn ? 4 : 3
        
        var arraySimilarArtists = [BandSimilar]()
        
        if let doc = try? Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) {
            if let tbody = doc.at_css("tbody") {
                for tr in tbody.css("tr") {
                    var bandName: String?
                    var bandURLString: String?
                    var bandCountry: Country?
                    var bandGenre: String?
                    var bandSimilarScore: Int?
                    var i = 0
                    for td in tr.css("td") {
                        
                        if (td["id"] == "no_artists" || td["id"] == "show_more") {
                            break
                        }
                        
                        if (i == nameColumn) {
                            if let a = td.at_css("a") {
                                bandName = a.text
                                bandURLString = a["href"]
                            }
                        }
                            
                        else if (i == countryColumn) {
                            if let countryName = td.text {
                                bandCountry = Country(name: countryName)
                            }
                        }
                            
                        else if (i == genreColumn) {
                            bandGenre = td.text
                        }
                            
                        else if (i == scoreColumn) {
                            if let span = td.at_css("span") {
                                bandSimilarScore = Int(span.text?.replacingOccurrences(of: " ", with: "") ?? "")
                            }
                        }
                        
                        i += 1
                    }
                    
                    if let name = bandName, let urlString = bandURLString, let country = bandCountry, let genre = bandGenre, let score = bandSimilarScore {
                        if let band = BandSimilar(name: name, urlString: urlString, country: country, genre: genre, score: score) {
                            arraySimilarArtists.append(band)
                        }
                    }
                    
                }
            }
        }
        
        if arraySimilarArtists.count == 0 {
            return nil
        }
        
        return arraySimilarArtists
    }
}
