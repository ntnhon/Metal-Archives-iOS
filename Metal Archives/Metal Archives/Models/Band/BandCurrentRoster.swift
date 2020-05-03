//
//  BandCurrentRoster.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class BandCurrentRoster: ThumbnailableObject, Pagable {
    let name: String
    let genre: String
    let country: Country
    
    static var rawRequestURLString = "https://www.metal-archives.com/label/ajax-bands/nbrPerPage/100/id/<LABEL_ID>?sEcho=1&iColumns=3&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=100&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&iSortCol_0=0&sSortDir_0=asc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true"
    static var displayLength = 100
    
    init?(from array: [String]) {
        //Workaround in case ' instead of "
        //from: <a href='https://www.metal-archives.com/bands/Red_Ruin/3540450310'>Red Ruin</a>
        //to: <a href=\"https://www.metal-archives.com/bands/Red_Ruin/3540450310\">Red Ruin</a>
        var a = array[0]
        a = a.replacingOccurrences(of: "href='", with: "href=\"")
        a = a.replacingOccurrences(of: "href=\'", with: "href=\"")
        a = a.replacingOccurrences(of: "'>", with: "\">")
        
        let bandName = String(a.subString(after: "\">", before: "</a>", options: .caseInsensitive) ?? "")
        let bandURLString = String(a.subString(after: "href=\"", before: "\">", options: .caseInsensitive) ?? "")
        
        let genre = array[1]
        let countryName = array[2]
        
        self.name = bandName
        self.genre = genre
        self.country = Country(name: countryName)
        super.init(urlString: bandURLString, imageType: .bandLogo)
    }
}
