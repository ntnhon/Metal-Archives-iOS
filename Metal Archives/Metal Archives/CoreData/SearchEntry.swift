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

    var placeholderSystemImageName: String? {
        switch self {
        case .bandNameQuery     : return "person.3.fill"
        case .musicGenreQuery   : return "guitars.fill"
        case .lyricalThemesQuery: return "music.quarternote.3"
        case .albumTitleQuery   : return "opticaldisc"
        case .songTitleQuery    : return "music.note.list"
        case .labelQuery        : return "tag.fill"
        case .artistQuery       : return "person.fill"
        case .userQuery         : return "person.crop.circle.fill"
        default                 : return nil
        }
    }
}

struct SearchEntry {
    let type: SearchEntryType
    /// When type is query, this will be the search term. Otherwise it'll be band name, label name, album title...
    let primaryDetail: String
    /// When type is query, this will be `null`. Otherwise it'll be the URL string of band, label, album...
    let secondaryDetail: String?

    var thumbnailInfo: ThumbnailInfo? {
        guard let secondaryDetail else { return nil }

        let thumbnailType: ThumbnailType?
        switch type {
        case .band: thumbnailType = .bandLogo
        case .release: thumbnailType = .release
        case .artist: thumbnailType = .artist
        case .label: thumbnailType = .label
        default: thumbnailType = nil
        }

        guard let thumbnailType else { return nil }
        return .init(urlString: secondaryDetail, type: thumbnailType)
    }
}

extension SearchEntry: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(type.rawValue)
        hasher.combine(primaryDetail)
        hasher.combine(secondaryDetail)
    }
}
