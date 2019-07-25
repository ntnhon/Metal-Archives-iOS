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
    let isInstrumental: Bool
    
    init(title: String, length: String, lyricID: String?, isInstrumental: Bool?) {
        self.length = length
        self.lyricID = lyricID
        self.isInstrumental = isInstrumental ?? false
        
        super.init(title: title, type: .song)
    }
}
