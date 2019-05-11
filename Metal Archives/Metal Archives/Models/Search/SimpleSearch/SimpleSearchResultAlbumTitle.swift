//
//  SimpleSearchResultAlbumTitle.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SimpleSearchResultAlbumTitle: ThumbnailableObject {
    let bands: [BandLite]
    let release: ReleaseExtraLite
    let type: String
    let dateString: String
    
    init?(bands: [BandLite], release: ReleaseExtraLite, type: String, dateString: String) {
        self.bands = bands
        self.release = release
        self.type = type
        self.dateString = dateString
        super.init(urlString: release.urlString, imageType: .release)
    }
}

//MARK: - Pagable
extension SimpleSearchResultAlbumTitle: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/search/ajax-album-search/?field=title&query=<QUERY>&sEcho=2&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3"
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [SimpleSearchResultAlbumTitle]?, totalRecords: Int?)? {
        var list: [SimpleSearchResultAlbumTitle] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listSimpleSearchResultAlbumTitle = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listSimpleSearchResultAlbumTitle.forEach { (eachDetail) in
            var bands: [BandLite]?
            
            if eachDetail.indices.contains(0) {
                bands = []
                let detailComponents = eachDetail[0].components(separatedBy: "|")
        
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
                    release = ReleaseExtraLite(urlString: urlString, name: releaseTitle)
                }
            }
            
            let type: String? = eachDetail.indices.contains(2) ? eachDetail[2] : nil
            
            var dateString: String?
            if eachDetail.indices.contains(3) {
                let detailComponents = eachDetail[3].components(separatedBy: " <!--")
                dateString = detailComponents.indices.contains(0) ? detailComponents[0] : nil
            }
            
            if let `bands` = bands, let `release` = release, let `type` = type, let `dateString` = dateString {
                if let result = SimpleSearchResultAlbumTitle(bands: bands, release: release, type: type, dateString: dateString) {
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
extension SimpleSearchResultAlbumTitle: Actionable {
    var actionableElements: [ActionableElement] {
        var elements: [ActionableElement] = []
        
        self.bands.forEach { (eachBand) in
            let bandElement = ActionableElement(name: eachBand.name, urlString: eachBand.urlString, type: .band)
            elements.append(bandElement)
        }
        
        let releaseElement = ActionableElement(name: self.release.name, urlString: self.release.urlString, type: .release)
        elements.append(releaseElement)
        
        return elements
    }

}
