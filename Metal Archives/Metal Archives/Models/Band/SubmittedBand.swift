//
//  SubmittedBand.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 15/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class SubmittedBand {
    let band: BandLite
    let genre: String
    let country: Country
    let date: String
    
    /*
     Sample array:
     "<a href='https://www.metal-archives.com/bands/Twin_Wizard/3540464901'>Twin Wizard</a>",
     "Stoner/Doom Metal",
     "United States",
     "March 18, 2020"
     */
    init?(from array: [String]) {
        guard array.count == 4 else { return nil }
        
        guard let urlSubstring = array[0].subString(after: #"href='"#, before: #"'>"#, options: .caseInsensitive),
            let nameSubstring = array[0].subString(after: #"'>"#, before: "</a>", options: .caseInsensitive) else {
                return nil
        }
        
        guard let band = BandLite(name: String(nameSubstring), urlString: String(urlSubstring)) else { return nil }
        
        self.band = band
        self.genre = array[1]
        self.country = Country(name: array[2])
        self.date = array[3]
    }
}

extension SubmittedBand: Pagable {
    static var rawRequestURLString = "https://www.metal-archives.com/band/ajax-list-user/id/<USER_ID>?sEcho=1&iColumns=4&sColumns=&iDisplayStart=<DISPLAY_START>&iDisplayLength=<DISPLAY_LENGTH>&mDataProp_0=0&mDataProp_1=1&mDataProp_2=2&mDataProp_3=3&iSortCol_0=<SORT_COLUMN>&sSortDir_0=<SORT_ORDER>&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=true&_=1586977685424"
    
    static var displayLength = 100
    
    static func parseListFrom(data: Data) -> (objects: [SubmittedBand]?, totalRecords: Int?)? {
        guard let (totalRecords, array) = parseTotalRecordsAndArrayOfRawValues(data) else {
            return nil
        }
        var list: [SubmittedBand] = []
        
        array.forEach { (submittedBandDetails) in
            if let submittedBand = SubmittedBand(from: submittedBandDetails) {
                list.append(submittedBand)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
