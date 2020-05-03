//
//  ReleaseInLabel.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ReleaseInLabel: ThumbnailableObject, Pagable {
    let bands: [BandLite]
    let release: ReleaseExtraLite
    let type: String
    let year: Int?
    let catalogID: String
    let format: String
    let releaseDescription: String
    
    static var rawRequestURLString = "https://www.metal-archives.com/label/ajax-albums/nbrPerPage/200/id/<LABEL_ID>?sEcho=1&iColumns=7&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&mDataProp_6=6&iSortCol_0=0&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=false&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=true&bSortable_6=false"
    
    static var displayLength = 200
    
    init?(from array: [String]) {
        let bandRawString = array[0].replacingOccurrences(of: " / ", with: "😡")
        let bandRawStringComponents = bandRawString.split(separator: "😡")
        var bands: [BandLite] = []
        for i in 0..<bandRawStringComponents.count {
            //Workaround is case ' instead of "
            //from: <a href='https://www.metal-archives.com/bands/Red_Ruin/3540450310'>Red Ruin</a>
            //to: <a href=\"https://www.metal-archives.com/bands/Red_Ruin/3540450310\">Red Ruin</a>
            var a = String(bandRawStringComponents[i])
            a = a.replacingOccurrences(of: "href='", with: "href=\"")
            a = a.replacingOccurrences(of: "href=\'", with: "href=\"")
            a = a.replacingOccurrences(of: "'>", with: "\">")
            
            let bandName = String(a.subString(after: "\">", before: "</a>", options: .caseInsensitive) ?? "")
            let bandURLString = String(a.subString(after: "href=\"", before: "\">", options: .caseInsensitive) ?? "")
            if let band = BandLite(name: bandName, urlString: bandURLString) {
                bands.append(band)
            }
        }
        
        //Workaround is case ' instead of "
        //from: <a href='https://www.metal-archives.com/bands/Red_Ruin/3540450310'>Red Ruin</a>
        //to: <a href=\"https://www.metal-archives.com/bands/Red_Ruin/3540450310\">Red Ruin</a>
        var a = array[1]
        a = a.replacingOccurrences(of: "href='", with: "href=\"")
        a = a.replacingOccurrences(of: "href=\'", with: "href=\"")
        a = a.replacingOccurrences(of: "'>", with: "\">")
        
        let releaseTitle = String(a.subString(after: "\">", before: "</a>", options: .caseInsensitive) ?? "")
        let releaseURLString = String(a.subString(after: "href=\"", before: "\">", options: .caseInsensitive) ?? "")
        let release = ReleaseExtraLite(urlString: releaseURLString, title: releaseTitle)
        let type = array[2]
        let year = Int(array[3])
        let catalogID = array[4]
        let format = array[5]
        let description = array[6]
        
        if let release = release {
            self.bands = bands
            self.release = release
            self.type = type
            self.year = year
            self.catalogID = catalogID
            self.format = format
            self.releaseDescription = description
            super.init(urlString: release.urlString, imageType: .release)
        } else {
            return nil
        }
    }
}

//MARK: - Actionable
extension ReleaseInLabel: Actionable {
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
