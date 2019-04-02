//
//  BandPastRoster.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class BandPastRoster: Thumbnailable {
    let name: String
    let genre: String
    let country: Country
    let numberOfReleases: Int
    
    init?(urlString: String, name: String, genre: String, country: Country, numberOfReleases: Int) {
        self.name = name
        self.genre = genre
        self.country = country
        self.numberOfReleases = numberOfReleases
        super.init(urlString: urlString, imageType: .bandLogo)
    }
}

extension BandPastRoster: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/label/ajax-bands-past/nbrPerPage/100/id/<LABEL_ID>?sEcho=1&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=100&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=0&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true&_=1551083484358"
    static var displayLenght = 100
    
    static func parseListFrom(data: Data) -> (objects: [BandPastRoster]?, totalRecords: Int?)? {
        var list: [BandPastRoster] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listPastRoster = json?["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json?["iTotalRecords"] as? Int
        
        listPastRoster.forEach { (eachBandPastRosterDetail) in
            
            //Workaround is case ' instead of "
            //from: <a href='https://www.metal-archives.com/bands/Red_Ruin/3540450310'>Red Ruin</a>
            //to: <a href=\"https://www.metal-archives.com/bands/Red_Ruin/3540450310\">Red Ruin</a>
            var a = eachBandPastRosterDetail[0]
            a = a.replacingOccurrences(of: "href='", with: "href=\"")
            a = a.replacingOccurrences(of: "href=\'", with: "href=\"")
            a = a.replacingOccurrences(of: "'>", with: "\">")
            
            let bandName = String(a.subString(after: "\">", before: "</a>", options: .caseInsensitive) ?? "")
            let bandURLString = String(a.subString(after: "href=\"", before: "\">", options: .caseInsensitive) ?? "")
            
            let genre = eachBandPastRosterDetail[1]
            let countryName = eachBandPastRosterDetail[2]
            let numberOfReleases = Int(eachBandPastRosterDetail[3])
            
            if let country = Country(name: countryName), let `numberOfReleases` = numberOfReleases {
                if let bandPastRoster = BandPastRoster(urlString: bandURLString, name: bandName, genre: genre, country: country, numberOfReleases: numberOfReleases) {
                    list.append(bandPastRoster)
                }
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
