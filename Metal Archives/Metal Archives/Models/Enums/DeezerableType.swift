//
//  DeezerableType.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 12/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum DeezerableType {
    case album, artist
    
    var requestParameterName: String {
        switch self {
        case .album: return "album"
        case .artist: return "artist"
        }
    }
}
