//
//  SimpleSearchResultBandName.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SimpleSearchResultBandName: SimpleSearchResultBandNameOrMusicGenre, Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-band-search/?field=name&query=<QUERY>&sEcho=2&iColumns=3&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2"
    
    static var displayLength = 200
    
    init?(from array: [String]) {
        var band: BandLite?
        var aka: String?
        
        if array.indices.contains(0) {
            var bandName: String?
            var urlString: String?
            
            if let subString = array[0].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                bandName = String(subString)
            }
            
            if let subString = array[0].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                urlString = String(subString)
            }
            
            if let `bandName` = bandName, let `urlString` = urlString {
                band = BandLite(name: bandName, urlString: urlString)
            }
            
            
            if array[0].contains("a.k.a") {
                if let subString = array[0].subString(after: "</a> (", before: ")", options: .caseInsensitive) {
                    aka = subString.replacingOccurrences(of: "<strong>", with: "").replacingOccurrences(of: "</strong>", with: "")
                    
                }
            }
        }
        
        let genre: String? = array.indices.contains(1) ? array[1] : nil
        
        let countryName: String? = array.indices.contains(2) ? array[2] : nil
        var country: Country?
        if let countryName = countryName {
            country = Country(name: countryName)
        }

        if let band = band, let genre = genre, let country = country {
            super.init(band: band, aka: aka, genre: genre, country: country)
        } else {
            return nil
        }
    }
}
