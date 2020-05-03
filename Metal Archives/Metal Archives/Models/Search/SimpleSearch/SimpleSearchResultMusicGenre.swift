//
//  SimpleSearchResultMusicGenre.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SimpleSearchResultMusicGenre: SimpleSearchResultBandNameOrMusicGenre, Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-band-search/?field=genre&query=<QUERY>&sEcho=2&iColumns=3&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2"
    static var displayLength = 200
    
    static func parseListFrom(data: Data) -> (objects: [SimpleSearchResultMusicGenre]?, totalRecords: Int?)? {
        var list: [SimpleSearchResultMusicGenre] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listSimpleSearchResultMusicGenre = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listSimpleSearchResultMusicGenre.forEach { (eachDetail) in
            var band: BandLite?
            var aka: String?
            
            if eachDetail.indices.contains(0) {
                var bandName: String?
                var urlString: String?
                
                if let subString = eachDetail[0].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                    bandName = String(subString)
                }
                
                if let subString = eachDetail[0].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                    urlString = String(subString)
                }
                
                if let `bandName` = bandName, let `urlString` = urlString {
                    band = BandLite(name: bandName, urlString: urlString)
                }
                
                
                if eachDetail[0].contains("a.k.a") {
                    if let subString = eachDetail[0].subString(after: "</a> (", before: ")", options: .caseInsensitive) {
                        aka = subString.replacingOccurrences(of: "<strong>", with: "").replacingOccurrences(of: "</strong>", with: "")
                        
                    }
                }
            }
            
            let genre: String? = eachDetail.indices.contains(1) ? eachDetail[1] : nil
            
            let countryName: String? = eachDetail.indices.contains(2) ? eachDetail[2] : nil
            var country: Country?
            if let `countryName` = countryName {
                country = Country(name: countryName)
            }
            
            if let `band` = band, let `genre` = genre, let `country` = country {
                if let result = SimpleSearchResultMusicGenre(band: band, aka: aka, genre: genre, country: country) {
                    list.append(result)
                }
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
