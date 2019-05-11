//
//  BandLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 30/01/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class BandLite: ThumbnailableObject {
    let name: String
    
    init?(name: String, urlString: String) {
        self.name = name
        super.init(urlString: urlString, imageType: .bandLogo)
    }
}
