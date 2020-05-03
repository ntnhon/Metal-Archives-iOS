//
//  SongAdvancedSearchResult.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class AdvancedSearchResultSong {
    let band: BandLite
    let release: ReleaseExtraLite
    let otherDetails: [String]
    
    init(band: BandLite, release: ReleaseExtraLite, otherDetails: [String]) {
        self.band = band
        self.release = release
        self.otherDetails = otherDetails
    }
}

//MARK: - Pagable
extension AdvancedSearchResultSong: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-advanced/searching/songs/?<OPTIONS_LIST>sEcho=1&iColumns=6&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5"
    
    static var displayLength = 200
    
    static func parseListFrom(data: Data) -> (objects: [AdvancedSearchResultSong]?, totalRecords: Int?)? {
        var list: [AdvancedSearchResultSong] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listSongAdvancedSearchResult = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listSongAdvancedSearchResult.forEach { (eachSearchResult) in
            var band: BandLite?
            
            if eachSearchResult.indices.contains(0) {
                var bandName: String?
                var urlString: String?
                if let subString = eachSearchResult[0].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                    bandName = String(subString)
                }
                
                if let subString = eachSearchResult[0].subString(after: "href=\"", before: "\" title", options: .caseInsensitive) {
                    urlString = String(subString)
                }
                
                if let `bandName` = bandName, let `urlString` = urlString {
                    band = BandLite(name: bandName, urlString: urlString)
                }
            }
            
            var release: ReleaseExtraLite?
            
            if eachSearchResult.indices.contains(1) {
                var releaseTitle: String?
                var urlString: String?
                
                if let subString = eachSearchResult[1].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                    releaseTitle = String(subString)
                }
                
                if let subString = eachSearchResult[1].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                    urlString = String(subString)
                }
                
                if let `releaseTitle` = releaseTitle, let `urlString` = urlString {
                    release = ReleaseExtraLite(urlString: urlString, title: releaseTitle)
                }
            }
            
            var otherDetails: [String] = []
            for i in 2..<eachSearchResult.count - 1 { //-1 cause the last detail is lyric
                otherDetails.append(eachSearchResult[i])
            }
            
            if let `band` = band, let `release` = release {
                let result = AdvancedSearchResultSong(band: band, release: release, otherDetails: otherDetails)
                list.append(result)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}

//MARK: - Actionable
extension AdvancedSearchResultSong: Actionable {
    var actionableElements: [ActionableElement] {
        let bandElement = ActionableElement.band(name: band.name, urlString: band.urlString)
        let releaseElement = ActionableElement.release(name: release.title, urlString: release.urlString)
        return [bandElement, releaseElement]
    }
}
