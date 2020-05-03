//
//  AlbumAdvancedSearchResult.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class AdvancedSearchResultAlbum: Pagable {
    let bands: [BandLite]
    let release: ReleaseExtraLite
    let otherDetails: [String]
    
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-advanced/searching/albums/?<OPTIONS_LIST>sEcho=5&iColumns=3&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2"
    
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
                
                if let subString = eachComponent.subString(after: "href=\"", before: "\" title", options: .caseInsensitive) {
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
        
        var otherDetails: [String] = []
        for i in 2..<array.count {
            otherDetails.append(array[i])
        }
        
        if let bands = bands, let release = release {
            self.bands = bands
            self.release = release
            self.otherDetails = otherDetails
        } else {
            return nil
        }
    }
}

//MARK: - Actionable
extension AdvancedSearchResultAlbum: Actionable {
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
