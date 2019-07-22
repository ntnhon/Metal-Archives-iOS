//
//  DeezerTrack.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

struct DeezerTrack: Decodable {
    let title: String
    let duration: Int
    let preview: String
    let artist: DeezerArtistLite
    let album: DeezerAlbumLite?
    
    var durationString: String {
        let minute = duration / 60
        let second = duration % 60
        return String(format: "%02d:%02d", minute, second)
    }
}
