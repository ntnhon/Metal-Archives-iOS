//
//  SimpleSearchType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 16/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum SimpleSearchType: Int, CustomStringConvertible, CaseIterable {
    case bandName = 0, musicGenre, lyricalThemes, albumTitle, songTitle, label, artist, user
    
    var description: String {
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
}
