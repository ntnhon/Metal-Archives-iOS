//
//  SimpleSearchResultLyricalThemes.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SimpleSearchResultLyricalThemes: Pagable {
    let band: BandLite
    let aka: String?
    let genre: String
    let country: Country
    let lyricalThemes: String
    
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-band-search/?field=themes&query=<QUERY>&sEcho=2&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3"
    
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
        if let `countryName` = countryName {
            country = Country(name: countryName)
        }
        
        let lyricalThemes: String? = array.indices.contains(3) ? array[3] : nil
        
        if let band = band, let genre = genre, let country = country, let lyricalThemes = lyricalThemes {
            self.band = band
            self.aka = aka
            self.genre = genre
            self.country = country
            self.lyricalThemes = lyricalThemes
        } else {
            return nil
        }
    }
}
