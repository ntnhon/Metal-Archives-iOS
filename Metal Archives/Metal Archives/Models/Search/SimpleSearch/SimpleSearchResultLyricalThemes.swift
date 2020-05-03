//
//  SimpleSearchResultLyricalThemes.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SimpleSearchResultLyricalThemes {
    let band: BandLite
    let aka: String?
    let genre: String
    let country: Country
    let lyricalThemes: String
    
    init?(band: BandLite, aka: String?, genre: String, country: Country, lyricalThemes: String) {
        self.band = band
        self.aka = aka
        self.genre = genre
        self.country = country
        self.lyricalThemes = lyricalThemes
    }
}

extension SimpleSearchResultLyricalThemes: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-band-search/?field=themes&query=<QUERY>&sEcho=2&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3"
    static var displayLength = 200
    
    static func parseListFrom(data: Data) -> (objects: [SimpleSearchResultLyricalThemes]?, totalRecords: Int?)? {
        var list: [SimpleSearchResultLyricalThemes] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listSimpleSearchResultLyricalThemes = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listSimpleSearchResultLyricalThemes.forEach { (eachDetail) in
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
            
            let lyricalThemes: String? = eachDetail.indices.contains(3) ? eachDetail[3] : nil
            
            if let `band` = band, let `genre` = genre, let `country` = country, let `lyricalThemes` = lyricalThemes {
                if let result = SimpleSearchResultLyricalThemes(band: band, aka: aka, genre: genre, country: country, lyricalThemes: lyricalThemes) {
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
