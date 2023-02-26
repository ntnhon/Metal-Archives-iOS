//
//  SimpleSearchType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/06/2021.
//

import Foundation

enum SimpleSearchType: CaseIterable {
    case bandName
    case musicGenre
    case lyricalThemes
    case albumTitle
    case songTitle
    case label
    case artist
    case user

    var title: String {
        switch self {
        case .bandName: return "Band name"
        case .musicGenre: return "Music genre"
        case .lyricalThemes: return "Lyrical themes"
        case .albumTitle: return "Album title"
        case .songTitle: return "Song title"
        case .label: return "Label"
        case .artist: return "Artist"
        case .user: return "User"
        }
    }

    var placeholder: String {
        switch self {
        case .bandName: return "e.g., death, testament"
        case .musicGenre: return "e.g., death metal, grindcore"
        case .lyricalThemes: return "e.g., society, religion"
        case .albumTitle: return "e.g., symbolic, dark roots of earth"
        case .songTitle: return "e.g., symbolic, rise up"
        case .label: return "e.g., nuclear blast, sony music"
        case .artist: return "e.g., chuck schuldiner, chuck billy"
        case .user: return "e.g., hellblazer, morrigan"
        }
    }

    var navigationTitle: String {
        switch self {
        case .bandName: return "Search by band name"
        case .musicGenre: return "Search by music genre"
        case .lyricalThemes: return "Search by lyrical themes"
        case .albumTitle: return "Search by album title"
        case .songTitle: return "Search by song title"
        case .label: return "Search labels"
        case .artist: return "Search artists"
        case .user: return "Search users"
        }
    }

    var imageName: String {
        switch self {
        case .bandName: return "person.3.fill"
        case .musicGenre: return "guitars.fill"
        case .lyricalThemes: return "music.quarternote.3"
        case .albumTitle: return "opticaldisc"
        case .songTitle: return "music.note.list"
        case .label: return "tag.fill"
        case .artist: return "person.fill"
        case .user: return "person.crop.circle.fill"
        }
    }
}
