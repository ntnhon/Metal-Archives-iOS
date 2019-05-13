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
        guard let (totalRecords, array) = parseTotalRecordsAndArrayOfRawValues(data) else {
            return nil
        }
        var list: [ArtistUpdate] = []
        
        array.forEach { (artistDetails) in
            if let artistAddition = ArtistUpdate(from: artistDetails) {
                list.append(artistAddition)
            }
        }
        
        if list.count == 0 {
            return (nil, nil)
        }
        return (list, totalRecords)
    }
}
