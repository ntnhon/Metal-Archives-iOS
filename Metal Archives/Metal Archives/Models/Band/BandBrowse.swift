//
//  BandBrowse.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

/// Use for Browse band: alphabetically, country and genre
final class BandBrowse: ThumbnailableObject, Pagable {
    let name: String
    let countryOrLocation: String
    let genre: String
    let status: BandStatus
    
    static var rawRequestURLString = "https://www.metal-archives.com/browse/<PARAMETER>/json/1?sEcho=1&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=500&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=0&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=false"
    static var displayLength = 500
    
    init?(from array: [String]) {
        var bandName: String?
        var bandURLString: String?
        
        if let subString = array[0].subString(after: "'>", before: "</a>", options: .caseInsensitive) {
            bandName = String(subString)
        }
        
        if let subString = array[0].subString(after: "href=\'", before: "'>", options: .caseInsensitive) {
            bandURLString = String(subString)
        }
        
        var countryOrLocation: String?
        var genre: String?
        
        let country = Country(name: array[1])
        if country != Country.unknownCountry {
            countryOrLocation = country.nameAndEmoji
            genre = array[2]
        } else {
            countryOrLocation = array[2]
            genre = array[1]
        }
        
        var status: BandStatus?
        
        if let subString = array[3].subString(after: "\">", before: "</", options: .caseInsensitive) {
            status = BandStatus(statusString: String(subString))
        }
        
        if let bandName = bandName, let bandURLString = bandURLString, let countryOrLocation = countryOrLocation, let genre = genre, let status = status {
            self.name = bandName
            self.countryOrLocation = countryOrLocation
            self.genre = genre
            self.status = status
            super.init(urlString: bandURLString, imageType: .bandLogo)
        } else {
            return nil
        }
    }
}
