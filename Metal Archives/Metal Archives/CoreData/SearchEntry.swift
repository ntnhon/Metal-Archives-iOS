//
//  SearchEntry.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/11/2022.
//

import Foundation

enum SearchEntryType: Int16 {
    case bandName           = 0
    case bandNameQuery      = 1
    case musicGenre         = 2
    case musicGenreQuery    = 3
    case lyricalThemes      = 4
    case lyricalThemesQuery = 5
    case albumTitle         = 6
    case albumTitleQuery    = 7
    case songTitle          = 8
    case songTitleQuery     = 9
    case label              = 10
    case labelQuery         = 11
    case artist             = 12
    case artistQuery        = 13
    case user               = 14
    case userQuery          = 15

    var isQueryEntry: Bool {
        switch self {
        case .bandNameQuery,
                .musicGenreQuery,
                .lyricalThemesQuery,
                .albumTitleQuery,
                .songTitleQuery,
                .labelQuery,
                .artistQuery,
                .userQuery:
            return true
        default:
            return false
        }
    }
}

struct SearchEntry {
    let type: SearchEntryType
    /// When type is query, this will be the search term. Otherwise it'll be band name, label name, album title...
    let primaryDetail: String
    /// When type is query, this will be `null`. Otherwise it'll be the URL string of band, label, album...
    let secondaryDetail: String?
}
