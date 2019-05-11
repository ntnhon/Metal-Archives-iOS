//
//  ArtistExtraLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 05/03/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ArtistExtraLite: ThumbnailableObject {
    let name: String
    
    init?(urlString: String, name: String) {
        self.name = name
        super.init(urlString: urlString, imageType: .artist)
    }
}
