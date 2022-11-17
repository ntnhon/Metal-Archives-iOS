//
//  SearchEntry.swift
//  Metal Archives
//
//  Created by Nhon Nguyen on 17/11/2022.
//

import Foundation

enum SearchEntryType: Int16 {
    case bandNameQuery      = 0
    case musicGenreQuery    = 1
    case lyricalThemesQuery = 2
    case albumTitleQuery    = 3
    case songTitleQuery     = 4
    case labelQuery         = 5
    case artistQuery        = 6
    case userQuery          = 7
    case band               = 8
    case release            = 9
    case artist             = 10
    case label              = 11
    case user               = 12

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

extension SearchEntry: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(type.rawValue)
        hasher.combine(primaryDetail)
        hasher.combine(secondaryDetail)
    }
}
