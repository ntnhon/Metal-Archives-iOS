//
//  BandAdvancedSearchResult.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class AdvancedSearchResultBand: Pagable {
    let band: BandLite
    let akaString: String?
    let otherDetails: [String]
    
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-advanced/searching/bands/?<OPTIONS_LIST>&sEcho=1&iColumns=6&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5"
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
        
        var otherDetails: [String] = []
        for i in 1..<array.count {
            let country = Country(name: array[i])
            if country != Country.unknownCountry {
                otherDetails.append(country.nameAndEmoji)
            } else {
                otherDetails.append(array[i])
            }
        }
        
        if let band = band {
            self.band = band
            self.akaString = aka
            self.otherDetails = otherDetails
        } else {
            return nil
        }
    }
}
