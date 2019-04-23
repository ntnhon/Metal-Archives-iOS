//
//  BandAddition.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class BandAddition: BandAdditionOrUpdate, Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/archives/ajax-band-list/selection/<YEAR_MONTH>/by/created//json/1?sEcho=1&iColumns=6&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=200&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&mDataProp_4=4&mDataProp_5=5&iSortCol_0=4&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true&bSortable_4=true&bSortable_5=true&_=1551173033645"
    
    static var displayLenght = 200
    
    static func parseListFrom(data: Data) -> (objects: [BandAddition]?, totalRecords: Int?)? {
        var list: [BandAddition] = []
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:Any],
            let listBandLatestAdditions = json["aaData"] as? [[String]]
            else {
                return nil
        }
        
        let totalRecords = json["iTotalRecords"] as? Int
        
        listBandLatestAdditions.forEach { (bandDetails) in
            
            let updatedDateString = bandDetails[0]
            let name = String((bandDetails[1].subString(after: "\">", before: "</a>", options: .caseInsensitive)) ?? "")
            let urlString = String(bandDetails[1].subString(after: "href=\"", before: "\">", options: .caseInsensitive) ?? "")
            let countryURLString = String(bandDetails[2].subString(after: "href=\"", before: "\">", options: .caseInsensitive) ?? "" )
            let genre = bandDetails[3]
            let updatedDateAndTimeString = bandDetails[4]
            
            if let bandAddition = BandAddition(updatedDateString: updatedDateString, name: name, urlString: urlString, countryURLString: countryURLString, genre: genre, updatedDateAndTimeString: updatedDateAndTimeString) {
                list.append(bandAddition)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
