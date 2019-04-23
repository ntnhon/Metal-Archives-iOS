//
//  ReleaseInLabel.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ReleaseInLabel: Thumbnailable {
    let bands: [BandLite]
    let release: ReleaseExtraLite
    let type: String
    let year: Int?
    let catalogID: String
    let format: String
    let releaseDescription: String
    
    init?(bands: [BandLite], release: ReleaseExtraLite, type: String, year: Int?, catalogID: String, format: String, releaseDescription: String) {
        self.bands = bands
        self.release = release
        self.type = type
        self.year = year
        self.catalogID = catalogID
        self.format = format
        self.releaseDescription = releaseDescription
        super.init(urlString: release.urlString, imageType: .release)
    }
}

//MARK: - Pagable
extension ReleaseInLabel: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/label/ajax-albums/nbrPerPage/200/id/<LABEL_ID>?sEcho=1&iColumns=7&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&mDataProp_6=6&iSortCol_0=0&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=false&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=true&bSortable_6=false&_=1551083484359"
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [ReleaseInLabel]?, totalRecords: Int?)? {
        var list: [ReleaseInLabel] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listRelease = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listRelease.forEach { (eachReleaseDetail) in
            let bandRawString = eachReleaseDetail[0].replacingOccurrences(of: " / ", with: "😡")
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
            var a = eachReleaseDetail[1]
            a = a.replacingOccurrences(of: "href='", with: "href=\"")
            a = a.replacingOccurrences(of: "href=\'", with: "href=\"")
            a = a.replacingOccurrences(of: "'>", with: "\">")
            
            let releaseName = String(a.subString(after: "\">", before: "</a>", options: .caseInsensitive) ?? "")
            let releaseURLString = String(a.subString(after: "href=\"", before: "\">", options: .caseInsensitive) ?? "")
            let release = ReleaseExtraLite(urlString: releaseURLString, name: releaseName)
            let type = eachReleaseDetail[2]
            let year = Int(eachReleaseDetail[3])
            let catalogID = eachReleaseDetail[4]
            let format = eachReleaseDetail[5]
            let description = eachReleaseDetail[6]
            
            if let `release` = release {
                if let releaseInLabel = ReleaseInLabel(bands: bands, release: release, type: type, year: year, catalogID: catalogID, format: format, releaseDescription: description) {
                    list.append(releaseInLabel)
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
extension ReleaseInLabel: Actionable {
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
