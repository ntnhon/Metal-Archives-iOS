//
//  ReleaseExtraLite.swift
//  Metal Archives
//
//  Created by Thanh-Nhon Nguyen on 24/02/2019.
//  Copyright © 2019 Thanh-Nhon Nguyen. All rights reserved.
//

import Foundation

final class ReleaseExtraLite: ThumbnailableObject {
    let name: String
    
    init?(urlString: String, name: String) {
        self.name = name
        super.init(urlString: urlString, imageType: .release)
    }
}
