//
//  SimpleSearchResultSongTitle.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SimpleSearchResultSongTitle: ThumbnailableObject {
    let band: BandNullable
    let release: ReleaseExtraLite
    let type: String
    let title: String
    
    init?(band: BandNullable, release: ReleaseExtraLite, type: String, title: String) {
        self.band = band
        self.release = release
        self.type = type
        self.title = title
        super.init(urlString: release.urlString, imageType: .release)
    }
}

//MARK: - Pagable
extension SimpleSearchResultSongTitle: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-song-search/?field=title&query=<QUERY>&sEcho=10&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3"
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [SimpleSearchResultSongTitle]?, totalRecords: Int?)? {
        var list: [SimpleSearchResultSongTitle] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listSimpleSearchResultSongTitle = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listSimpleSearchResultSongTitle.forEach { (eachDetail) in
            var band: BandNullable?
            
            if eachDetail.indices.contains(0) {
                var bandName: String?
                var urlString: String?
                
                if let subString = eachDetail[0].subString(after: "\">", before: "</", options: .caseInsensitive) {
                    bandName = String(subString)
                }
                
                if let subString = eachDetail[0].subString(after: "href=\"", before: "\"", options: .caseInsensitive) {
                    urlString = String(subString)
                }
                
                if let `bandName` = bandName {
                    band = BandNullable(name: bandName, urlString: urlString)
                }
            }
            
            var release: ReleaseExtraLite?
            
            if eachDetail.indices.contains(1) {
                var releaseTitle: String?
                var urlString: String?
                
                if let subString = eachDetail[1].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                    releaseTitle = String(subString)
                }
                
                if let subString = eachDetail[1].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                    urlString = String(subString)
                }
                
                if let `releaseTitle` = releaseTitle, let `urlString` = urlString {
                    release = ReleaseExtraLite(urlString: urlString, title: releaseTitle)
                }
            }
            
            let type: String? = eachDetail.indices.contains(2) ? eachDetail[2] : nil
            let title: String? = eachDetail.indices.contains(3) ? eachDetail[3] : nil
            
            if let `band` = band, let `release` = release, let `type` = type, let `title` = title {
                if let result = SimpleSearchResultSongTitle(band: band, release: release, type: type, title: title) {
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

//MARK: - Actionable
extension SimpleSearchResultSongTitle: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        if let bandURLString = self.band.urlString {
            let bandElement = ActionableElement.band(name: band.name, urlString: bandURLString)
            elements.append(bandElement)
        }
        
        let releaseElement = ActionableElement.release(name: release.title, urlString: release.urlString)
        elements.append(releaseElement)
        return elements
    }
}
