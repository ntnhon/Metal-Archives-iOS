//
//  ReleaseStatistic.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 27/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ReleaseStatistic {
    let albums: Int
    let songs: Int
    
    init(albums: Int, songs: Int) {
        self.albums = albums
        self.songs = songs
    }
}
