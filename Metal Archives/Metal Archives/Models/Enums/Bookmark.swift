//
//  Bookmark.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 11/04/2020.
//  Copyright © 2020 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

enum BookmarkAction: String {
    case add = "add", remove = "remove"
}

enum BookmarkType: Int {
    case band = 1, label = 2, artist = 3, release = 4
}
