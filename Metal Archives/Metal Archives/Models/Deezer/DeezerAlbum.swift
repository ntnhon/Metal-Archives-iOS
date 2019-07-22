//
//  DeezerAlbum.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

struct DeezerAlbum: Decodable {
    let title: String
    let cover_xl: String
    let release_date: String?
    let record_type: String
    let tracklist: String
    let artist: DeezerArtistLite
}
