//
//  BandCurrentRoster.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class BandCurrentRoster: ThumbnailableObject {
    let name: String
    let genre: String
    let country: Country
    
    init?(urlString: String, name: String, genre: String, country: Country) {
        self.name = name
        self.genre = genre
        self.country = country
        super.init(urlString: urlString, imageType: .bandLogo)
    }
}

extension BandCurrentRoster: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/label/ajax-bands/nbrPerPage/100/id/<LABEL_ID>?sEcho=1&iColumns=3&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=100&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&iSortCol_0=0&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&_=1551083484357"
    static var displayLenght = 100
    
    static func parseListFrom(data: Data) -> (objects: [BandCurrentRoster]?, totalRecords: Int?)? {
        var list: [BandCurrentRoster] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listCurrentRoster = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listCurrentRoster.forEach { (eachBandCurrentRosterDetail) in
            //Workaround is case ' instead of "
            //from: <a href='https://www.metal-archives.com/bands/Red_Ruin/3540450310'>Red Ruin</a>
            //to: <a href=\"https://www.metal-archives.com/bands/Red_Ruin/3540450310\">Red Ruin</a>
            var a = eachBandCurrentRosterDetail[0]
            a = a.replacingOccurrences(of: "href='", with: "href=\"")
            a = a.replacingOccurrences(of: "href=\'", with: "href=\"")
            a = a.replacingOccurrences(of: "'>", with: "\">")
            
            let bandName = String(a.subString(after: "\">", before: "</a>", options: .caseInsensitive) ?? "")
            let bandURLString = String(a.subString(after: "href=\"", before: "\">", options: .caseInsensitive) ?? "")
            
            let genre = eachBandCurrentRosterDetail[1]
            let countryName = eachBandCurrentRosterDetail[2]
            
            if let country = Country(name: countryName) {
                if let bandCurrentRoster = BandCurrentRoster(urlString: bandURLString, name: bandName, genre: genre, country: country) {
                    list.append(bandCurrentRoster)
                }
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
