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
    let preview: String
    let artist: DeezerArtistLite
    let album: DeezerAlbumLite?
}
