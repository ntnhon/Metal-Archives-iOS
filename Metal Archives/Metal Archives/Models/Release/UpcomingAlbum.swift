//
//  UpcomingAlbum.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class UpcomingAlbum: Thumbnailable {
    let bands: [BandLite]
    let release: ReleaseExtraLite
    let releaseType: String
    let genre: String
    let date: String
    
    init?(bands: [BandLite], release: ReleaseExtraLite, releaseType: String, genre: String, date: String) {
        self.bands = bands
        self.release = release
        self.releaseType = releaseType
        self.genre = genre
        self.date = date
        super.init(urlString: release.urlString, imageType: .release)
    }
}

//MARK: - Pagable
extension UpcomingAlbum: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/release/ajax-upcoming/json/1?sEcho=1&iColumns=5&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=100&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&iSortCol_0=4&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true"
    static var displayLenght = 100
    
    static func parseListFrom(data: Data) -> (objects: [UpcomingAlbum]?, totalRecords: Int?)? {
        var list: [UpcomingAlbum] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listUpcomingAlbums = json["aaData"] as? [[String]]
            else {
            return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listUpcomingAlbums.forEach { (upcomingAlbumDetail) in
            
            let bandRawString = upcomingAlbumDetail[0].replacingOccurrences(of: " / ", with: "😡")
            let bandRawStringComponents = bandRawString.split(separator: "😡")
            var bands: [BandLite] = []
            for i in 0..<bandRawStringComponents.count {
                let bandString = bandRawStringComponents[i]
                
                if let bandNameSubString = bandString.subString(after: "\">", before: "</a>", options: .caseInsensitive),
                    let bandURLSubString = bandString.subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                    
                    if let band = BandLite(name: String(bandNameSubString), urlString: String(bandURLSubString)) {
                        bands.append(band)
                    }
                }
            }
            
            var release: ReleaseExtraLite?
            if let releaseNameSubString = upcomingAlbumDetail[1].subString(after: "\">", before: "</a>", options: .caseInsensitive),
                let releaseURLSubString = upcomingAlbumDetail[1].subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                release = ReleaseExtraLite(urlString: String(releaseURLSubString), name: String(releaseNameSubString))
            }
            let releaseType = upcomingAlbumDetail[2]
            let genre = upcomingAlbumDetail[3]
            let date = upcomingAlbumDetail[4]
            
            if let `release` = release, let upcomingAlbum = UpcomingAlbum(bands: bands, release: release, releaseType: releaseType, genre: genre, date: date) {
                list.append(upcomingAlbum)
            }
            
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}

//MARK: - Actionable
extension UpcomingAlbum: Actionable {
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
