//
//  ArtistAddition.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 26/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ArtistAddition: ArtistAdditionOrUpdate, Pagable {
    //swiftlint:disable:next line_length
    static var rawRequestURLString = "https://www.metal-archives.com/archives/ajax-artist-list/selection/<YEAR_MONTH>/by/created/json/1?sEcho=5&iColumns=6&sColumns=&iDisplayStart=<DISPLAY_START>rop_4=4&mDataProp_5=5&iSortCol_0=4&sSortDir_0=desc&iSortingCols=1&bSortable_0=true&bSortable_1=true&bSortable_2=true&bSortable_3=false&bSortable_4=true&bSortable_5=true&_=1551172813084"
    static var displayLength = 200

    static func parseListFrom(data: Data) -> (objects: [ArtistAddition]?, totalRecords: Int?)? {
        guard let (totalRecords, array) = parseTotalRecordsAndArrayOfRawValues(data) else {
            return nil
        }
        var list: [ArtistAddition] = []
        
        array.forEach { artistDetails in
            if let artistAddition = ArtistAddition(from: artistDetails) {
                list.append(artistAddition)
            }
        }

        if list.isEmpty { return (nil, nil) }
        return (list, totalRecords)
    }
}
