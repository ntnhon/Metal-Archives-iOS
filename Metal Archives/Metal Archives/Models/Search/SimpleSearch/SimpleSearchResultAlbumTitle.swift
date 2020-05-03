//
//  SimpleSearchResultAlbumTitle.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SimpleSearchResultAlbumTitle: ThumbnailableObject, Pagable {
    let bands: [BandLite]
    let release: ReleaseExtraLite
    let type: String
    let dateString: String
    
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-album-search/?field=title&query=<QUERY>&sEcho=2&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3"
    
    static var displayLength = 200
    
    init?(from array: [String]) {
        var bands: [BandLite]?
        
        if array.indices.contains(0) {
            bands = []
            let detailComponents = array[0].components(separatedBy: "|")
            
            detailComponents.forEach({ (eachComponent) in
                var bandName: String?
                var urlString: String?
                if let subString = eachComponent.subString(after: "\">", before: "</a>", options: .caseInsensitive) {
                    bandName = String(subString)
                }
                
                if let subString = eachComponent.subString(after: "href=\"", before: "\"", options: .caseInsensitive) {
                    urlString = String(subString)
                }
                
                if let `bandName` = bandName, let `urlString` = urlString {
                    if let band = BandLite(name: bandName, urlString: urlString) {
                        bands?.append(band)
                    }
                }
            })
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
        
        var dateString: String?
        if array.indices.contains(3) {
            let detailComponents = array[3].components(separatedBy: " <!--")
            dateString = detailComponents.indices.contains(0) ? detailComponents[0] : nil
        }
        
        if let bands = bands, let release = release, let type = type, let dateString = dateString {
            self.bands = bands
            self.release = release
            self.type = type
            self.dateString = dateString
            super.init(urlString: release.urlString, imageType: .release)
        } else {
            return nil
        }
    }
}

//MARK: - Actionable
extension SimpleSearchResultAlbumTitle: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        self.bands.forEach { (eachBand) in
            let bandElement = ActionableElement.band(name: eachBand.name, urlString: eachBand.urlString)
            elements.append(bandElement)
        }
        
        let releaseElement = ActionableElement.release(name: release.title, urlString: release.urlString)
        elements.append(releaseElement)
        
        return elements
    }

}
