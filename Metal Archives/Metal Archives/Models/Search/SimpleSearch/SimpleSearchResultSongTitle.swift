//
//  SimpleSearchResultSongTitle.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SimpleSearchResultSongTitle: ThumbnailableObject, Pagable {
    let band: BandNullable
    let release: ReleaseExtraLite
    let type: String
    let title: String
    
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-song-search/?field=title&query=<QUERY>&sEcho=10&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3"
    
    static var displayLength = 200
    
    init?(from array: [String]) {
        var band: BandNullable?
        
        if array.indices.contains(0) {
            var bandName: String?
            var urlString: String?
            
            if let subString = array[0].subString(after: "\">", before: "</", options: .caseInsensitive) {
                bandName = String(subString)
            }
            
            if let subString = array[0].subString(after: "href=\"", before: "\"", options: .caseInsensitive) {
                urlString = String(subString)
            }
            
            if let `bandName` = bandName {
                band = BandNullable(name: bandName, urlString: urlString)
            }
        }
        
        var release: ReleaseExtraLite?
        
        if array.indices.contains(1) {
            var releaseTitle: String?
            var urlString: String?
            
            if let subString = array[1].subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                releaseTitle = String(subString)
            }
            
            if let subString = array[1].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                urlString = String(subString)
            }
            
            if let `releaseTitle` = releaseTitle, let `urlString` = urlString {
                release = ReleaseExtraLite(urlString: urlString, title: releaseTitle)
            }
        }
        
        let type: String? = array.indices.contains(2) ? array[2] : nil
        let title: String? = array.indices.contains(3) ? array[3] : nil
        
        if let band = band, let release = release, let type = type, let title = title {
            self.band = band
            self.release = release
            self.type = type
            self.title = title
            super.init(urlString: release.urlString, imageType: .release)
        } else {
            return nil
        }
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
