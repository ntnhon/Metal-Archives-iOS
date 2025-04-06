//
//  SimpleSearchType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/06/2021.
//

import Foundation

enum SimpleSearchType: CaseIterable, Sendable {
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
        case .bandName:
            "Band name"
        case .musicGenre:
            "Music genre"
        case .lyricalThemes:
            "Lyrical themes"
        case .albumTitle:
            "Album title"
        case .songTitle:
            "Song title"
        case .label:
            "Label"
        case .artist:
            "Artist"
        case .user:
            "User"
        }
    }

    var placeholder: String {
        switch self {
        case .bandName:
            "e.g., death, testament"
        case .musicGenre:
            "e.g., death metal, grindcore"
        case .lyricalThemes:
            "e.g., society, religion"
        case .albumTitle:
            "e.g., symbolic, dark roots of earth"
        case .songTitle:
            "e.g., symbolic, rise up"
        case .label:
            "e.g., nuclear blast, sony music"
        case .artist:
            "e.g., chuck schuldiner, chuck billy"
        case .user:
            "e.g., hellblazer, morrigan"
        }
    }

    var navigationTitle: String {
        switch self {
        case .bandName:
            "Search by band name"
        case .musicGenre:
            "Search by music genre"
        case .lyricalThemes:
            "Search by lyrical themes"
        case .albumTitle:
            "Search by album title"
        case .songTitle:
            "Search by song title"
        case .label:
            "Search labels"
        case .artist:
            "Search artists"
        case .user:
            "Search users"
        }
    }

    var imageName: String {
        switch self {
        case .bandName:
            "person.3.fill"
        case .musicGenre:
            "guitars.fill"
        case .lyricalThemes:
            "music.quarternote.3"
        case .albumTitle:
            "opticaldisc"
        case .songTitle:
            "music.note.list"
        case .label:
            "tag.fill"
        case .artist:
            "person.fill"
        case .user:
            "person.crop.circle.fill"
        }
    }
}
