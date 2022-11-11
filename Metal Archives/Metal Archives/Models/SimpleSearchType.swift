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
}
