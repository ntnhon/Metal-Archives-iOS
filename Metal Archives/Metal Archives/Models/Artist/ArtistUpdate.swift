//
//  ArtistUpdate.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation
final class ArtistUpdate: ArtistAdditionOrUpdate, Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/archives/ajax-artist-list/selection/<YEAR_MONTH>/by/modified/json/1?sEcho=3&iColumns=6&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&iSortCol_0=4&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=false&bSortable_4=true&bSortable_5=true&_=1551206585343"
    
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [ArtistUpdate]?, totalRecords: Int?)? {
        var list: [ArtistUpdate] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listBandLatestAdditions = json?["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json?["iTotalRecords"] as? Int
        
        listBandLatestAdditions.forEach { (bandDetails) in
            
            let nameInBand = String((bandDetails[1].subString(after: "\">", before: "</a>", options: .caseInsensitive)) ?? "")
            let urlString = String(bandDetails[1].subString(after: "href=\"", before: "\">", options: .caseInsensitive) ?? "")
            var realFullName: String?
            if let realFullNameSubString = bandDetails[1].subString(after: "(", before: ")", options: .caseInsensitive) {
                realFullName = String(realFullNameSubString)
            }
            
            let countryName = bandDetails[2].replacingOccurrences(of: "</a>", with: "")
            let country = Country(name: countryName)
            
            var bands: [BandLite] = []
            //Parse list of bands
            bandDetails[3].components(separatedBy: ",").forEach({ (eachATag) in
                
                if let bandNameSubString = eachATag.subString(after: "\">", before: "</a>", options: .caseInsensitive),
                    let bandURLSubString = eachATag.subString(after: "href=\"", before: "\">", options: .caseInsensitive) {
                    if let band = BandLite(name: String(bandNameSubString), urlString: String(bandURLSubString)) {
                        bands.append(band)
                    }
                }
            })
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let updatedDate = dateFormatter.date(from: bandDetails[4])
            
            if let `updatedDate` = updatedDate {
                if let artist = ArtistUpdate(urlString: urlString, nameInBand: nameInBand, realFullName: realFullName, country: country, bands: bands, updatedDate: updatedDate) {
                    list.append(artist)
                }
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
