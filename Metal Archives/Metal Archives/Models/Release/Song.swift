//
//  Song.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class Song: ReleaseElement {
    let length: String
    let lyricID: String?
    
    init(title: String, length: String, lyricID: String?) {
        self.length = length
        self.lyricID = lyricID
        
        super.init(title: title, type: .song)
    }
}
