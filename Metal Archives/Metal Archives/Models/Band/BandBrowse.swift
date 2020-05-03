//
//  BandBrowse.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 13/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

//Use for Browse band: alphabetically, country and genre
final class BandBrowse: ThumbnailableObject {
    let name: String
    let countryOrLocation: String
    let genre: String
    let status: BandStatus
    
    init?(urlString: String, name: String, countryOrLocation: String, genre: String, status: BandStatus) {
        self.name = name
        self.countryOrLocation = countryOrLocation
        self.genre = genre
        self.status = status
        super.init(urlString: urlString, imageType: .bandLogo)
    }
}

//MARK: - Pagable
extension BandBrowse: Pagable {
    
    static var rawRequestURLString = "https://www.metal-archives.com/browse/<PARAMETER>/json/1?sEcho=1&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=500&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=0&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=false"
    static var displayLength = 500
    
    static func parseListFrom(data: Data) -> (objects: [BandBrowse]?, totalRecords: Int?)? {
        var list: [BandBrowse] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listBandBrowse = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listBandBrowse.forEach { (bandDetails) in
            var bandName: String?
            var bandURLString: String?
            
            if let subString = bandDetails[0].subString(after: "'>", before: "</a>", options: .caseInsensitive) {
                bandName = String(subString)
            }
            
            if let subString = bandDetails[0].subString(after: "href=\'", before: "'>", options: .caseInsensitive) {
                bandURLString = String(subString)
            }
            
            var countryOrLocation: String?
            var genre: String?
            
            let country = Country(name: bandDetails[1])
            if country != Country.unknownCountry {
                countryOrLocation = country.nameAndEmoji
                genre = bandDetails[2]
            } else {
                countryOrLocation = bandDetails[2]
                genre = bandDetails[1]
            }
            
            var status: BandStatus?
            
            if let subString = bandDetails[3].subString(after: "\">", before: "</", options: .caseInsensitive) {
                status = BandStatus(statusString: String(subString))
            }
            
            if let `bandName` = bandName, let `bandURLString` = bandURLString, let `countryOrLocation` = countryOrLocation, let `genre` = genre, let `status` = status {
                if let band = BandBrowse(urlString: bandURLString, name: bandName, countryOrLocation: countryOrLocation, genre: genre, status: status) {
                    list.append(band)
                }
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
