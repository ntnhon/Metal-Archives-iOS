//
//  DeezerArtist.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 21/07/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

struct DeezerArtist: Decodable {
    let id: Int
    let name: String
    let link: String
    let picture: String
    let picture_small: String
    let picture_medium: String
    let picture_big: String
    let picture_xl: String
    let nb_album: Int
    let nb_fan: Int
    let radio: Bool
    let tracklist: String
    let type: String
}
