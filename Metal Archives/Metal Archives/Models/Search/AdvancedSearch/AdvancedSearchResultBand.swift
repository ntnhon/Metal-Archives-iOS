//
//  BandAdvancedSearchResult.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class AdvancedSearchResultBand {
    let band: BandLite
    let akaString: String?
    let otherDetails: [String]
    
    init(band: BandLite, akaString: String?, otherDetails: [String]) {
        self.band = band
        self.akaString = akaString
        self.otherDetails = otherDetails
    }
}

extension AdvancedSearchResultBand: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-advanced/searching/bands/?<OPTIONS_LIST>&sEcho=1&iColumns=6&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5"
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [AdvancedSearchResultBand]?, totalRecords: Int?)? {
        var list: [AdvancedSearchResultBand] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listBandAdvancedSearchResult = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listBandAdvancedSearchResult.forEach { (eachSearchResult) in
            var band: BandLite?
            var aka: String?
            
            if eachSearchResult.indices.contains(0) {
                var bandName: String?
                var urlString: String?
                if let subString = eachSearchResult[0].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                    bandName = String(subString)
                }
                
                if let subString = eachSearchResult[0].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                    urlString = String(subString)
                }
                
                if let `bandName` = bandName, let `urlString` = urlString {
                    band = BandLite(name: bandName, urlString: urlString)
                }
                
                if eachSearchResult[0].contains("a.k.a") {
                    if let subString = eachSearchResult[0].subString(after: "</a> (", before: ")", options: .caseInsensitive) {
                        aka = subString.replacingOccurrences(of: "<strong>", with: "").replacingOccurrences(of: "</strong>", with: "")
                        
                    }
                }
            }
            
            var otherDetails: [String] = []
            for i in 1..<eachSearchResult.count {
                otherDetails.append(eachSearchResult[i])
            }
            
            if let `band` = band {
                let result = AdvancedSearchResultBand(band: band, akaString: aka, otherDetails: otherDetails)
                list.append(result)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
